import type { ElementType, ReactNode } from 'react';

type IconButtonProps = {
    label: string;
    icon: ElementType;
    children?: ReactNode;
    onClick?: () => void;
};

export default function IconButton({ label, icon: Icon, children, onClick }: IconButtonProps) {
    return (
        <button
            type="button"
            aria-label={label}
            onClick={onClick}
            className="flex h-12 items-center justify-center gap-2 rounded-full border-2 border-black px-4 theme-accent-hover"
        >
            <Icon strokeWidth={1.5} />
            <span>{children ?? label}</span>
        </button>
    );
}
