import type { ElementType } from 'react'
import { Link } from '@tanstack/react-router'
import HoverText from './HoverText'

type SidebarLink = '/' | '/notes' | '/chat' | '/calendar' | '/shop' | '/social' | '/settings'

type SidebarNavItemProps = {
    icon: ElementType
    label: string
    to: SidebarLink
    collapsed: boolean
}

export default function SidebarNavItem({ icon: Icon, label, to, collapsed }: SidebarNavItemProps) {
    const iconElement = <Icon strokeWidth={1.25} />

    return (
        <Link
            to={to}
            activeProps={{ className: 'bg-gray-200' }}
            className="flex items-start gap-1.5 rounded-md p-1.5 group hover:bg-gray-200 cursor-pointer"
        >
            {collapsed ? <HoverText msg={label} dir="right">{iconElement}</HoverText> : iconElement}
            {!collapsed && <p>{label}</p>}
        </Link>
    )
}