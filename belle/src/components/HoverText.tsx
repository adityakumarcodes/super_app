import { Tooltip } from "radix-ui";
import type { ReactNode } from "react";

interface HoverTextProps {
    children: ReactNode;
    msg: string;
    dir: 'top' | 'bottom' | 'right' | 'left';
}

const HoverText: React.FC<HoverTextProps> = ({ children, msg, dir }) => {
    return <Tooltip.Provider delayDuration={0}     >
        <Tooltip.Root>
            <Tooltip.Trigger asChild>
                {/* <button> cannot be a descendant of <button></button> */}
                {/* Radix UI components support asChild, which tells them not to render their own <button> and instead use your element. */}
                {children}
            </Tooltip.Trigger >
            <Tooltip.Portal>
                <Tooltip.Content side={dir} sideOffset={20} className="rounded-sm bg-gray-200 p-2 ">
                    <p>{msg}</p>
                </Tooltip.Content>
            </Tooltip.Portal>
        </Tooltip.Root>
    </Tooltip.Provider>

}

export default HoverText