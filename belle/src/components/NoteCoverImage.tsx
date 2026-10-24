const bundledImages = import.meta.glob(
  "/src/images/notes/*.{jpg,jpeg,jfif,png}",
  {
    eager: true,
    import: "default",
  },
) as Record<string, string>;

// Values that can be used as an <img src> as-is.
const isDisplayUrl = (value: string) =>
  /^(?:https?:|data:|blob:|\/)/i.test(value);

// Older notes stored just a filename that maps to a bundled image.
function getBundledImage(value: string) {
  if (isDisplayUrl(value)) return undefined;

  const imageName = value.split("/").pop();
  return imageName
    ? bundledImages[`/src/images/notes/${imageName}`]
    : undefined;
}

type NoteCoverImageProps = {
  /** Stored cover value (`note.imageUrl`). */
  value?: string | null;
  /** Display-ready URL from the API (`note.coverUrl`). */
  src?: string | null;
  alt: string;
  className?: string;
  loading?: "lazy" | "eager";
};

export default function NoteCoverImage({
  value,
  src,
  alt,
  className,
  loading,
}: NoteCoverImageProps) {
  const fallback = value
    ? (getBundledImage(value) ?? (isDisplayUrl(value) ? value : undefined))
    : undefined;
  const imageSrc = src ?? fallback;

  if (!imageSrc) return null;

  return (
    <img src={imageSrc} alt={alt} className={className} loading={loading} />
  );
}
