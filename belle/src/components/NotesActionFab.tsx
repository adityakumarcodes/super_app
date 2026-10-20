import {
    FilePlus2,
    ImagePlus,
    Mic,
    Plus,
    QrCode,
    Trash2,
    X,
} from 'lucide-react'
import { useEffect, useRef, useState } from 'react'

export type NewNoteDraft = {
    title: string
    coverFile: File | null
}

type NotesActionFabProps = {
    onNewNote: (draft: NewNoteDraft) => void
    onNotice: (message: string) => void
}

export default function NotesActionFab({
    onNewNote,
    onNotice,
}: NotesActionFabProps) {
    const [actionsOpen, setActionsOpen] = useState(false)
    const [dialogOpen, setDialogOpen] = useState(false)
    const [title, setTitle] = useState('')
    const [coverImage, setCoverImage] = useState<string | null>(null)
    const [coverFile, setCoverFile] = useState<File | null>(null)
    const [coverError, setCoverError] = useState<string | null>(null)

    const imageInputRef = useRef<HTMLInputElement>(null)
    const qrInputRef = useRef<HTMLInputElement>(null)
    const coverInputRef = useRef<HTMLInputElement>(null)
    const coverPreviewRef = useRef<string | null>(null)

    useEffect(() => () => {
        if (coverPreviewRef.current) {
            URL.revokeObjectURL(coverPreviewRef.current)
        }
    }, [])

    const setCoverPreview = (file: File | null) => {
        if (coverPreviewRef.current) {
            URL.revokeObjectURL(coverPreviewRef.current)
        }

        const preview = file ? URL.createObjectURL(file) : null
        coverPreviewRef.current = preview
        setCoverImage(preview)
    }

    const handleNewNote = () => {
        setActionsOpen(false)
        setTitle('')
        setCoverPreview(null)
        setCoverFile(null)
        setCoverError(null)
        setDialogOpen(true)
    }

    const selectCover = (file?: File) => {
        if (!file) return

        if (!file.type.startsWith('image/')) {
            setCoverError('Please select a valid image.')
            return
        }

        if (file.size > 5 * 1024 * 1024) {
            setCoverError('Choose an image smaller than 5 MB.')
            return
        }

        setCoverFile(file)
        setCoverPreview(file)
        setCoverError(null)
    }

    const continueToEditor = () => {
        onNewNote({
            title: title.trim(),
            coverFile,
        })

        setDialogOpen(false)
    }

    return (
        <>
            {/* Initial cover image selection */}
            <input
                ref={coverInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={(event) => {
                    selectCover(event.target.files?.[0])
                    event.target.value = ''
                }}
            />

            {/* Existing image action */}
            <input
                ref={imageInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                className="hidden"
                aria-label="Choose an image"
                onChange={(event) => {
                    if (event.target.files?.[0]) {
                        onNotice(
                            'Image attachment is not implemented yet.',
                        )
                    }

                    event.target.value = ''
                }}
            />

            {/* Existing QR action */}
            <input
                ref={qrInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                className="hidden"
                aria-label="Choose a QR code image"
                onChange={(event) => {
                    if (event.target.files?.[0]) {
                        onNotice(
                            'QR code scanning is not implemented yet.',
                        )
                    }

                    event.target.value = ''
                }}
            />

            {/* FAB */}
            <div className="fixed bottom-4 left-1/2 z-20 -translate-x-1/2">
                {actionsOpen && (
                    <div className="surface-card mb-2 flex flex-wrap items-center justify-center gap-2 p-2 shadow-lg">
                        <button
                            type="button"
                            onClick={handleNewNote}
                            className="control-pill flex items-center gap-2 border border-strong px-4 py-2.5 text-base hover-surface-card"
                        >
                            <FilePlus2 size={19} />
                            New note
                        </button>

                        <button
                            type="button"
                            onClick={() => {
                                setActionsOpen(false)
                                onNotice(
                                    'Audio recording is not implemented yet.',
                                )
                            }}
                            className="control-pill flex items-center gap-2 border border-strong px-4 py-2.5 text-base hover-surface-card"
                        >
                            <Mic size={19} />
                            Record audio
                        </button>

                        <button
                            type="button"
                            onClick={() => qrInputRef.current?.click()}
                            className="control-pill flex items-center gap-2 border border-strong px-4 py-2.5 text-base hover-surface-card"
                        >
                            <QrCode size={19} />
                            Scan QR
                        </button>

                        <button
                            type="button"
                            onClick={() => imageInputRef.current?.click()}
                            className="control-pill flex items-center gap-2 border border-strong px-4 py-2.5 text-base hover-surface-card"
                        >
                            <ImagePlus size={19} />
                            Take image
                        </button>
                    </div>
                )}

                <button
                    type="button"
                    aria-expanded={actionsOpen}
                    aria-label={
                        actionsOpen ? 'Close note actions' : 'Open note actions'
                    }
                    onClick={() => setActionsOpen((open) => !open)}
                    className="theme-accent-bg control-pill mx-auto flex items-center gap-2 border border-strong px-5 py-3.5 text-base font-medium shadow-lg"
                >
                    {actionsOpen ? <X size={20} /> : <Plus size={20} />}
                    {actionsOpen ? 'Close' : 'Add note'}
                </button>
            </div>

            {/* Create note dialog */}
            {dialogOpen && (
                <div
                    className="surface-body fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-black/40 p-4"
                    onMouseDown={(event) => {
                        if (event.target === event.currentTarget) {
                            setDialogOpen(false)
                        }
                    }}
                >
                    <section
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="create-note-title"
                        className="surface-card w-full max-w-lg rounded-3xl border-2 border-strong p-5 md:p-7"
                    >
                        <header className="mb-6 flex items-center justify-between gap-4">
                            <div>
                                <h2
                                    id="create-note-title"
                                    className="font-bodoni text-3xl"
                                >
                                    Create a note
                                </h2>

                                <p className="mt-1 text-sm text-secondary">
                                    Give your note a title and cover.
                                </p>
                            </div>

                            <button
                                type="button"
                                onClick={() => setDialogOpen(false)}
                                className="control-pill border border-subtle p-2"
                                aria-label="Close dialog"
                            >
                                <X size={19} />
                            </button>
                        </header>

                        {/* Cover preview */}
                        {coverImage ? (
                            <div className="relative mb-5 overflow-hidden rounded-2xl border border-strong">
                                <img
                                    src={coverImage}
                                    alt="Note cover preview"
                                    className="h-44 w-full object-cover"
                                />

                                <button
                                    type="button"
                                    onClick={() => {
                                        setCoverPreview(null)
                                        setCoverFile(null)
                                        setCoverError(null)
                                    }}
                                    className="control-pill absolute right-2 top-2 flex items-center gap-2 border border-strong bg-white px-3 py-2 text-sm text-black"
                                >
                                    <Trash2 size={15} />
                                    Remove
                                </button>
                            </div>
                        ) : (
                            <button
                                type="button"
                                onClick={() => coverInputRef.current?.click()}
                                className="mb-5 flex h-36 w-full flex-col items-center justify-center gap-2 rounded-2xl border-2 border-dashed border-strong text-secondary transition hover-surface-card"
                            >
                                <ImagePlus size={28} />
                                <span className="font-medium">
                                    Add a cover image
                                </span>
                                <span className="text-xs">
                                    PNG, JPG or WebP · Max 5 MB
                                </span>
                            </button>
                        )}

                        {/* Title */}
                        <label
                            htmlFor="new-note-title"
                            className="mb-2 block text-sm font-medium"
                        >
                            Note title
                        </label>

                        <input
                            id="new-note-title"
                            autoFocus
                            value={title}
                            onChange={(event) => setTitle(event.target.value)}
                            onKeyDown={(event) => {
                                if (
                                    event.key === 'Enter' &&
                                    title.trim()
                                ) {
                                    continueToEditor()
                                }
                            }}
                            placeholder="e.g. My learning journal"
                            maxLength={200}
                            className="w-full rounded-xl border-2 border-strong bg-transparent px-4 py-3 outline-none focus:ring-2 focus:ring-black/10"
                        />

                        {coverError && (
                            <p
                                role="alert"
                                className="mt-3 text-sm text-red-700"
                            >
                                {coverError}
                            </p>
                        )}

                        {/* Actions */}
                        <footer className="mt-7 flex justify-end gap-3">
                            <button
                                type="button"
                                onClick={() => setDialogOpen(false)}
                                className="control-pill border border-strong px-4 py-2.5"
                            >
                                Cancel
                            </button>

                            <button
                                type="button"
                                disabled={!title.trim()}
                                onClick={continueToEditor}
                                className="theme-accent-bg control-pill flex items-center gap-2 border border-strong px-5 py-2.5 font-medium disabled:cursor-not-allowed disabled:opacity-50"
                            >
                                Continue
                                <FilePlus2 size={17} />
                            </button>
                        </footer>
                    </section>
                </div>
            )}
        </>
    )
}