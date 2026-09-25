
import type { ElementType, ReactNode } from 'react';

type IconButtonProps = {
    label: string;
    icon: ElementType;
    children?: ReactNode;
    onClick?: () => void;
    active?: boolean;
};

export default function IconButton({ label, icon: Icon, children, onClick, active = false }: IconButtonProps) {
    return (
        <button
            type="button"
            aria-label={label}
            aria-pressed={active}
            onClick={onClick}
            className={`flex h-12 items-center justify-center gap-2 rounded-full border-2 border-black px-4 transition ${active ? 'theme-accent-bg shadow-[0_5px_0_rgba(47,45,45,0.22)] -translate-y-0.5' : 'theme-accent-hover hover:-translate-y-0.5'}`}
        >
            <Icon strokeWidth={1.5} />
            <span>{children ?? label}</span>
        </button>
    );
}
