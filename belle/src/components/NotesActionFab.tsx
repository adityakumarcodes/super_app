import { FilePlus2, ImagePlus, Mic, Plus, QrCode, X } from 'lucide-react'
import { useRef, useState } from 'react'

type NotesActionFabProps = {
    onNewNote: () => void
    onNotice: (message: string) => void
}

export default function NotesActionFab({
    onNewNote,
    onNotice,
}: NotesActionFabProps) {
    const [actionsOpen, setActionsOpen] = useState(false)
    const imageInputRef = useRef<HTMLInputElement>(null)
    const qrInputRef = useRef<HTMLInputElement>(null)

    const handleNewNote = () => {
        setActionsOpen(false)
        onNewNote()
    }

    return (
        <>
            <input
                ref={imageInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                className="hidden"
                aria-label="Choose an image"
                onChange={(event) => {
                    const file = event.target.files?.[0]

                    if (file) {
                        onNotice(
                            'Image attachment is not implemented yet.',
                        )
                    }

                    event.target.value = ''
                }}
            />

            <input
                ref={qrInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                className="hidden"
                aria-label="Choose a QR code image"
                onChange={(event) => {
                    const file = event.target.files?.[0]

                    if (file) {
                        onNotice('QR code scanning is not implemented yet.')
                    }

                    event.target.value = ''
                }}
            />

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
                            onClick={() =>
                                onNotice(
                                    'Audio recording is not implemented yet.',
                                )
                            }
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
        </>
    )
}