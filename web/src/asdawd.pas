  inherited;
  if VarToStr(cxDBParcelas.DataController.Values[cxDBParcelas.DataController.FocusedRecordIndex,cxID_Duplicata.Index]) <> '' then
  begin
          ZTabela.sql.clear;
          ZTabela.sql.add('select Valor,Valor_pago,vlr_moeda from duplicata');
          Ztabela.sql.add(' where id_duplicata = :pID');
          ZTabela.open;

    if not Ztabela.isEmpty then
    begin
      Application.createForm(TFrmDuplicataAddEvento,frmDuplicataAddEvento);
      //AddEvento.MostrarAlerta := False;
      AddEvento.medOperacao.Text:= '81';

      AddEvento.FormStyle := fsNormal;
      frmDuplicataMovimento.AbreDuplicata(VarToStr(cxDBParcelas.DataController.Values[cxDBParcelas.DataController.FocusedRecordIndex,cxID_Duplicata.Index]));
    end;
  end;

 cxpage.activepageindex := 1;
  if (FDuplicata = nil) or ( not FDuplicata.Existe ) then
  begin
    Aviso('Nenhuma duplicata selecionada!');
    medDuplicata.setFocus;
    exit;
  end;

  if FDuplicata.Situacao = tsdCAN then
  begin
    Informa('Duplicata está cancelada! Não é permitido incluir novos eventos.');
    exit;
  end;

  if (FDuplicata.Situacao = tsdLIQ) and (FDuplicata.Antecipacao_Pedidosn) then
  begin
    Informa('Duplicata está LIQUIDADA! Não é permitido incluir novos eventos.');
    exit;
  end;

  if FDuplicata.isDuplicataAntecipacaoCredito then
  begin
    ZTabela.sql.Clear;
    ZTabela.sql.add('SELECT Item ');
    ZTabela.sql.add('  FROM cliente_lanc_antecipacao ');
    ZTabela.sql.add('  WHERE Exists(SELECT 1 FROM Duplicata_movimento dpm');
    ZTabela.sql.add('                 WHERE dpm.id_duplicata= :pid');
    ZTabela.sql.add('                   AND dpm.operacao = ( select dupoperacao_credantec from empresas where empresa = :pEmpresa )');
    ZTabela.sql.add('               )');
    ZTabela.sql.add('    AND Empresa = :PEmpresa ');
    ZTabela.sql.add('    AND id_Duplicata = :pID ');
    ZTabela.sql.add('    AND multi = 1 ');
    Ztabela.parambyname('pID').asSTring := VarToStr(cxDBParcelas.DataController.Values[cxDBParcelas.DataController.FocusedRecordIndex,cxID_Duplicata.Index]);
    ZTabela.parambyname('PEmpresa').asString := Formdata.Empresa;
    ZTabela.open;
    if (not ztabela.isempty)  then
    begin
      ztabela.close;
      informa('Duplicata de antecipação não permite criar eventos.');
      Exit;
    end;
    ZTabela.sql.Clear;
    ztabela.close;
  end;

  if      ( FDuplicata.DadosAgrupamento.id <> '' )
      and ( NOT FDuplicata.DadosAgrupamento.Documento_Agrupador )
      and ( NOT FDuplicata.DadosAgrupamento.Endossada ) then
  begin
    informa('Duplicata agrupada! Eventos não são permitidos.');
    exit;
  end;

  Application.CreateForm(TFrmDuplicataAddEvento,FrmDuplicataAddEvento);

  FrmDuplicataAddEvento.Empresa      := medEmpresa.text;
  FrmDuplicataAddEvento.TipoOperacao := FTipoOperacao;

  FrmDuplicataAddEvento.Parametro    := Parametro; //pagar...
  FrmDuplicataAddEvento.medEstrutFin.Enabled := (Parametro<>1);// nao pode ser pagar....  pagar tem q cair pela especie de custo.
  FrmDuplicataAddEvento.medEspecie_lanc.Text := FDuplicata.Provisao_Esp_Lanc;
  FrmDuplicataAddEvento.medEspecie_lanc.ConsultaCampoChave;

  FrmDuplicataAddEvento.medHistorico.Text := FrmDuplicataAddEvento.medEspecie_lanc.FieldByname('Historico');
  FrmDuplicataAddEvento.medHistorico.ConsultaCampoChave;

  FrmDuplicataAddEvento.medEstrutFin.Text := FDuplicata.GetPlanoFinanceiroEstrutura;
  FrmDuplicataAddEvento.Parametro := self.Parametro;

  if FDuplicata.Tipo_Pagamento > 0  then
  begin
    FrmDuplicataAddEvento.medTipoPgto.Text := IntToStr(FDuplicata.Tipo_Pagamento);
    FrmDuplicataAddEvento.medTipoPgto.ConsultaCampoChave;
  end;

  //So tenta busca a estrutura financeira, caso nao esteja informada ainda...
  // Existem casos onde existe apenas a estrutura financeira - Não podemos vincular a ESPECIE - Caso NT
  //Cheques a comepnsar, onde se possuir especie, contabiliza na conta errada.
  if (Parametro =1) and (trim(FrmDuplicataAddEvento.medEstrutFin.Text) = '') then
    FrmDuplicataAddEvento.medEstrutFin.Text := FDuplicata.GetPlanoFinanceiroEstrutura;

  FrmDuplicataAddEvento.medEstrutFin.ConsultaCampoChave;

  FrmDuplicataAddEvento.medCaixa.text := fduplicata.caixa.Codigo;
  FrmDuplicataAddEvento.medCaixa.ConsultaCampoChave;

  FrmDuplicataAddEvento.AddDuplicata(FDuplicata.ID, FDuplicata.Vlr - FDuplicata.Vlr_Pago);

  //FrmDuplicataAddEvento.AlteracaoCombinacao := tacQuitacao;

  FrmDuplicataAddEvento.ShowModal;

  FreeAndNil(FrmDuplicataAddEvento);
  AbreDuplicata(FDuplicata.ID);
end;