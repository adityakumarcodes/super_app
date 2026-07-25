import { useState, type ElementType } from 'react';
import { Link } from '@tanstack/react-router';
import {
    BookOpen,
    House,
    Plus,
    Trash2,
    ChevronDown,
    Bolt,
    Pyramid,
    Store,
    ChevronLeft,
    Maximize,
    Minimize,
    MessageCircleMore,
} from 'lucide-react';
import HoverText from './HoverText';
import Tree from './Tree';

type BaseMenuItem = {
    icon: ElementType;
    label: string;
};

type LinkMenuItem = BaseMenuItem & {
    type: 'link';
    link: string;
};

type AccordionMenuItem = BaseMenuItem & {
    type: 'accordion';
};

type MenuItem = LinkMenuItem | AccordionMenuItem;

type SidebarProps = {
    collapsed: boolean;
    onToggle: () => void;
};

const Sidebar = ({ collapsed, onToggle }: SidebarProps) => {
    const [isOpen, setIsOpen] = useState(false);
    const [isFullscreen, setIsFullscreen] = useState(false);

    const toggleFullscreen = () => {
        if (!document.fullscreenElement) {
            document.documentElement.requestFullscreen().then(() => setIsFullscreen(true));
        } else {
            document.exitFullscreen().then(() => setIsFullscreen(false));
        }
    };

    const menuItems: MenuItem[] = [
        { type: 'link', label: 'Home', icon: House, link: '/' },
        { type: 'link', label: 'Notes', icon: BookOpen, link: '/notes' },
        { type: 'link', label: 'Chat', icon: MessageCircleMore, link: '/chat' },
        { type: 'link', label: 'Shop', icon: Store, link: '/shop' },
        { type: 'link', label: 'Social', icon: Pyramid, link: '/social' },

        // { type: 'accordion', label: 'Notebook', icon: BookOpen },
    ];

    const maybeTooltip = (children: React.ReactNode, msg: string, dir: 'top' | 'bottom' | 'right' | 'left') =>
        collapsed ? <HoverText msg={msg} dir={dir}>{children}</HoverText> : <>{children}</>;

    return (
        <div className="flex h-full flex-col">
            <div className="flex items-center justify-end p-1">
                {maybeTooltip(
                    <button
                        type="button"
                        onClick={onToggle}
                        className="rounded-md p-1 text-gray-600 hover:bg-gray-200"
                        aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
                    >
                        <ChevronLeft strokeWidth={1.25} className={`transition-transform ${collapsed ? 'rotate-180' : ''}`} />
                    </button>,
                    collapsed ? 'Expand sidebar' : 'Collapse sidebar',
                    'right',
                )}
            </div>

            <div className="grow">
                {menuItems.map((item, index) => (
                    <div key={index}>
                        {item.type === 'accordion' ? (
                            <div>
                                <div
                                    onClick={() => setIsOpen(!isOpen)}
                                    className="flex items-start gap-1.5 group hover:bg-gray-200 rounded-md p-1.5 cursor-pointer"
                                >
                                    {maybeTooltip(<item.icon strokeWidth={1.25} />, item.label, 'right')}
                                    {!collapsed && <p className="grow">{item.label}</p>}
                                    {maybeTooltip(
                                        <Plus strokeWidth={1.5} className={`group-hover:opacity-100 opacity-0 text-gray-500 hover:bg-gray-300 rounded-md`} />,
                                        'Add new page',
                                        'bottom',
                                    )}
                                    <ChevronDown strokeWidth={1.25} onClick={() => setIsOpen(!isOpen)} className={`transition-transform duration-200 group-hover:inline text-gray-500 hover:bg-gray-300 rounded-md ${isOpen ? 'rotate-180' : ''}`} />
                                </div>
                                {isOpen && !collapsed && (
                                    <div className="ml-2">
                                        <Tree />
                                    </div>
                                )}
                            </div>
                        ) : (
                            <Link to={item.link} className="flex items-start gap-1.5 group hover:bg-gray-200 rounded-md p-1.5 cursor-pointer">
                                {maybeTooltip(<item.icon strokeWidth={1.25} />, item.label, 'right')}
                                {!collapsed && <p>{item.label}</p>}
                            </Link>
                        )}
                    </div>
                ))}
            </div>

            <div className="mt-auto pb-4">
                <hr className="my-2 border-t-2 border-gray-300" />
                {maybeTooltip(
                    <button onClick={toggleFullscreen} className="p-2">
                        {isFullscreen ? <Minimize size={20} /> : <Maximize size={20} />}
                    </button>,
                    'Toggle fullscreen',
                    'right',
                )}
                <a href="/settings" className="flex items-start gap-1.5 rounded-md p-1.5 group hover:bg-gray-200 cursor-pointer">
                    {maybeTooltip(<Bolt strokeWidth={1.25} />, 'Settings', 'right')}
                    {!collapsed && <p>Settings</p>}
                </a>
                <a href="/trash" className="flex items-start gap-1.5 rounded-md p-1.5 group hover:bg-gray-200 cursor-pointer">
                    {maybeTooltip(<Trash2 strokeWidth={1.25} />, 'Trash', 'right')}
                    {!collapsed && <p>Trash</p>}
                </a>
            </div>
        </div>
    );
};

export default Sidebar;
