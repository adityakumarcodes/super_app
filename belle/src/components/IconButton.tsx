import type { ElementType, ReactNode } from 'react';

type IconButtonProps = {
    label: string;
    icon: ElementType;
    children?: ReactNode;
};

export default function IconButton({ label, icon: Icon, children }: IconButtonProps) {
    return (
        <button
            type="button"
            aria-label={label}
            className="flex h-12 items-center justify-center gap-2 rounded-full border-2 border-black px-4 hover:bg-orange-200"
        >
            <Icon strokeWidth={1.5} />
            <span>{children ?? label}</span>
        </button>
    );
}
