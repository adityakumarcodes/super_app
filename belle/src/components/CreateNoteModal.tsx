import { ImagePlus, LoaderCircle, X } from 'lucide-react'
import { useRef, useState } from 'react'

type CreateNoteModalProps = {
    onClose: () => void
    onCreate: (title: string, cover?: File) => Promise<void>
}

export default function CreateNoteModal({
    onClose,
    onCreate,
}: CreateNoteModalProps) {
    const [title, setTitle] = useState('')
    const [cover, setCover] = useState<File | undefined>()
    const [error, setError] = useState<string | null>(null)
    const [creating, setCreating] = useState(false)

    const inputRef = useRef<HTMLInputElement>(null)

    const selectCover = (file?: File) => {
        if (!file) return

        if (!file.type.startsWith('image/')) {
            setError('Please select an image.')
            return
        }

        if (file.size > 5 * 1024 * 1024) {
            setError('Image must be smaller than 5 MB.')
            return
        }

        setCover(file)
        setError(null)
    }

    const create = async () => {
        if (!title.trim()) {
            setError('Enter a title for your note.')
            return
        }

        setCreating(true)
        setError(null)

        try {
            await onCreate(title.trim(), cover)
        } catch {
            setError('Could not create your note. Please try again.')
        } finally {
            setCreating(false)
        }
    }

    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center
                bg-black/40 p-4 backdrop-blur-sm"
            onMouseDown={(event) => {
                if (event.target === event.currentTarget && !creating) {
                    onClose()
                }
            }}
        >
            <section
                role="dialog"
                aria-modal="true"
                aria-labelledby="create-note-title"
                className="w-full max-w-lg rounded-3xl border-2
                    border-black bg-[var(--surface-body)] p-6"
            >
                <header className="mb-6 flex items-center justify-between">
                    <h2
                        id="create-note-title"
                        className="font-bodoni text-3xl"
                    >
                        Create a note
                    </h2>

                    <button
                        type="button"
                        onClick={onClose}
                        disabled={creating}
                        aria-label="Close dialog"
                        className="control-pill p-2"
                    >
                        <X size={18} />
                    </button>
                </header>

                <label
                    htmlFor="new-note-title"
                    className="mb-2 block text-sm font-medium"
                >
                    Title
                </label>

                <input
                    id="new-note-title"
                    autoFocus
                    maxLength={200}
                    value={title}
                    onChange={(event) => setTitle(event.target.value)}
                    placeholder="Untitled note"
                    className="mb-6 w-full rounded-xl border-2
                        border-black bg-transparent px-4 py-3 outline-none
                        focus:ring-2 focus:ring-black/10"
                />

                <p className="mb-2 text-sm font-medium">Cover image</p>

                <input
                    ref={inputRef}
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(event) => {
                        selectCover(event.target.files?.[0])

                        // Allow selecting the same file again.
                        event.currentTarget.value = ''
                    }}
                />

                {cover ? (
                    <div className="relative mb-6">
                        <img
                            src={URL.createObjectURL(cover)}
                            alt="Selected cover preview"
                            className="h-44 w-full rounded-2xl
                                border-2 border-black object-cover"
                        />

                        <button
                            type="button"
                            onClick={() => setCover(undefined)}
                            className="control-pill absolute right-2 top-2
                                border border-black bg-white px-3 py-2 text-sm"
                        >
                            Remove
                        </button>
                    </div>
                ) : (
                    <button
                        type="button"
                        onClick={() => inputRef.current?.click()}
                        className="mb-6 flex h-36 w-full flex-col
                            items-center justify-center gap-2 rounded-2xl
                            border-2 border-dashed border-black/40
                            text-secondary hover:bg-black/5"
                    >
                        <ImagePlus size={24} />
                        <span className="text-sm">
                            Upload a cover image
                        </span>
                    </button>
                )}

                {error && (
                    <p role="alert" className="mb-4 text-sm text-red-700">
                        {error}
                    </p>
                )}

                <footer className="flex justify-end gap-3">
                    <button
                        type="button"
                        onClick={onClose}
                        disabled={creating}
                        className="control-pill border border-subtle px-4 py-2"
                    >
                        Cancel
                    </button>

                    <button
                        type="button"
                        onClick={() => void create()}
                        disabled={!title.trim() || creating}
                        className="control-pill theme-accent-bg
                            inline-flex items-center gap-2 border-2
                            border-black px-5 py-2 font-medium
                            disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {creating && (
                            <LoaderCircle size={16} className="animate-spin" />
                        )}
                        {creating ? 'Creating…' : 'Create note'}
                    </button>
                </footer>
            </section>
        </div>
    )
}