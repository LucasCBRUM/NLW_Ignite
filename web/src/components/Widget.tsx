import { ChatTeardropDots } from "phosphor-react"; //4.6k (gzipped: 1.3k)
import {Popover} from '@headlessui/react'
import { WidgetForm } from "./WidgetForm";

export function Widget(){
    /*const [isWidgetOpen, setWidgetOpen] = useState(false)

    function toggleWidgetVisibility(){
        setWidgetOpen(!isWidgetOpen)
    }*/

/*{ isWidgetOpen ? <p> Hello World!</p> : null }
    { isWidgetOpen && <p> Hello World!</p>}
é substituido por:*/


    return (
        <Popover className="absolute bottom-5 right-5 md:bottom-8 md:right-8 flex flex-col items-end">  
        <Popover.Panel>
        <WidgetForm />
        </Popover.Panel>        
        <Popover.Button className="bg-violet-500 rounded-full px-3 h-12 text-white flex items-center group">
            <ChatTeardropDots className="w-6 h-6"/>
                <span className="max-w-0 overflow-hidden group-hover:max-w-xs transition-all duration-500 ease-linear">
                    <span className="pl-2"></span>
                    FeedBack
                </span>
            </Popover.Button>
        </Popover>
    )
}

