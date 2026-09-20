import type { HTMLAttributes } from 'react'

type SurfaceCardProps = HTMLAttributes<HTMLDivElement>

export default function SurfaceCard({ className = '', ...props }: SurfaceCardProps) {
    return <div className={`surface-card ${className}`} {...props} />
}