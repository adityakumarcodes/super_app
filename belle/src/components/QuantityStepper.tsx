import { Minus, Plus } from 'lucide-react'

type QuantityStepperProps = {
    value: number
    onChange: (value: number) => void
}

export default function QuantityStepper({ value, onChange }: QuantityStepperProps) {
    return (
        <div className="control-pill flex items-center gap-3 border border-strong px-2 py-1">
            <button
                type="button"
                aria-label="Decrease quantity"
                onClick={() => onChange(Math.max(1, value - 1))}
                className="flex h-8 w-8 items-center justify-center rounded-full border border-strong"
            >
                <Minus size={14} />
            </button>
            <span className="min-w-5 text-center text-lg">{value}</span>
            <button
                type="button"
                aria-label="Increase quantity"
                onClick={() => onChange(value + 1)}
                className="flex h-8 w-8 items-center justify-center rounded-full border border-strong"
            >
                <Plus size={14} />
            </button>
        </div>
    )
}