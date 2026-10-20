import { useSignedUrl } from '../utils/storageApi'

const bundledImages = import.meta.glob(
    '/src/images/notes/*.{jpg,jpeg,jfif,png}',
    {
        eager: true,
        import: 'default',
    },
) as Record<string, string>

// Older notes stored just a filename that maps to a bundled image.
function getBundledImage(value: string) {
    if (/^(?:https?:|data:|blob:|\/)/i.test(value)) return undefined

    const imageName = value.split('/').pop()
    return imageName ? bundledImages[`/src/images/notes/${imageName}`] : undefined
}

type NoteCoverImageProps = {
    value?: string | null
    alt: string
    className?: string
    loading?: 'lazy' | 'eager'
}

export default function NoteCoverImage({
    value,
    alt,
    className,
    loading,
}: NoteCoverImageProps) {
    const bundled = value ? getBundledImage(value) : undefined
    const signed = useSignedUrl(bundled ? null : value)
    const src = bundled ?? signed

    if (!src) return null

    return <img src={src} alt={alt} className={className} loading={loading} />
}
