import EditorJS, { type OutputData } from '@editorjs/editorjs'
import { Check, ImagePlus, Trash2, X } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import { EDITOR_JS_TOOLS } from '../constants/editorConfig'
import { editorDataToBlocks, type Note } from '../utils/noteDrafts'

type NoteComposerModalProps = {
    note?: Note
    onClose: () => void
    onSave: (note: Note) => void
}

export default function NoteComposerModal({ note, onClose, onSave }: NoteComposerModalProps) {
    const [title, setTitle] = useState(note?.title ?? '')
    const [description, setDescription] = useState(note?.description ?? '')
    const [coverImage, setCoverImage] = useState(note?.imageUrl ?? '')
    const [coverError, setCoverError] = useState<string | null>(null)
    const editorRef = useRef<EditorJS | null>(null)
    const coverInputRef = useRef<HTMLInputElement>(null)
    const holderId = 'note-composer-editor'

    useEffect(() => {
        const data: OutputData = {
            time: Date.now(),
            blocks: (note?.blocks ?? []).map((block) => ({
                id: block.blockKey ?? String(block.id),
                type: block.type,
                data: block.data,
            })),
            version: note?.editorVersion ?? undefined,
        }

        const editor = new EditorJS({
            holder: holderId,
            tools: EDITOR_JS_TOOLS,
            data,
            placeholder: 'Start writing your note…',
            autofocus: !note,
        })
        editorRef.current = editor

        return () => {
            if (typeof editor.destroy === 'function') {
                editor.destroy()
            } else {
                document.getElementById(holderId)?.replaceChildren()
            }

            if (editorRef.current === editor) {
                editorRef.current = null
            }
        }
    }, [note])

    const save = async () => {
        const output = await editorRef.current?.save() ?? { time: Date.now(), blocks: [] }
        onSave({
            ...note,
            id: note?.id ?? `draft-${crypto.randomUUID()}`,
            title: title.trim() || 'Untitled note',
            description: description.trim(),
            imageUrl: coverImage || null,
            blocks: editorDataToBlocks(output),
            editorVersion: output.version,
            isLocal: note?.isLocal ?? !note,
            createdAt: note?.createdAt ?? new Date().toISOString(),
        })
    }

    const selectCover = (file?: File) => {
        if (!file) return
        if (!file.type.startsWith('image/')) {
            setCoverError('Choose an image file for the cover.')
            return
        }
        if (file.size > 2 * 1024 * 1024) {
            setCoverError('Choose an image smaller than 2 MB for a local draft.')
            return
        }

        const reader = new FileReader()
        reader.onload = () => {
            setCoverImage(String(reader.result))
            setCoverError(null)
        }
        reader.onerror = () => setCoverError('The cover image could not be read. Please try another file.')
        reader.readAsDataURL(file)
    }

    return (
        <div className="surface-body fixed inset-0 z-50 overflow-y-auto" role="dialog" aria-modal="true" aria-label="Note editor">
            <section className="min-h-screen w-full">
                <header className="sticky top-0 z-10 border-b border-subtle bg-[var(--surface-body)]/95 px-4 py-3 backdrop-blur md:px-8">
                    <div className="mx-auto flex max-w-5xl items-center justify-between gap-4">
                        <button type="button" onClick={onClose} className="control-pill inline-flex items-center gap-2 px-3 py-2 text-sm text-secondary hover:bg-black/5" aria-label="Close editor"><X size={18} />Close</button>
                        <div className="flex items-center gap-2">
                            <span className="hidden text-sm text-secondary sm:inline">{note ? 'Editing local version' : 'Local draft'}</span>
                            <button type="button" onClick={() => void save()} className="theme-accent-bg control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 font-medium"><Check size={18} />Save</button>
                        </div>
                    </div>
                </header>
                <main className="mx-auto w-full max-w-5xl px-4 pb-20 pt-10 md:px-8">
                    <header className="mb-12 max-w-4xl">
                        {/* <p className="mb-5 text-sm text-secondary">{note ? 'Edit page' : 'Untitled page'}</p> */}
                        <input ref={coverInputRef} type="file" accept="image/*" className="hidden" onChange={(event) => selectCover(event.target.files?.[0])} />
                        {coverImage ? (
                            <div className="group relative mb-8 overflow-hidden rounded-3xl border border-strong">
                                <img src={coverImage} alt="Selected note cover" className="h-52 w-full object-cover md:h-64" />
                                <button type="button" onClick={() => { setCoverImage(''); setCoverError(null) }} className="control-pill absolute right-3 top-3 inline-flex items-center gap-2 border border-strong bg-[var(--surface-body)]/95 px-3 py-2 text-sm shadow-sm"><Trash2 size={15} />Remove cover</button>
                            </div>
                        ) : (
                            <button type="button" onClick={() => coverInputRef.current?.click()} className="control-pill mb-8 inline-flex items-center gap-2 border border-subtle px-3 py-2 text-sm text-secondary hover-surface-card"><ImagePlus size={17} />Add cover</button>
                        )}
                        {coverError && <p className="-mt-5 mb-5 text-sm text-red-700">{coverError}</p>}
                        <input id="note-title" value={title} onChange={(event) => setTitle(event.target.value)} placeholder="Untitled" aria-label="Note title" className="w-full bg-transparent font-bodoni text-5xl leading-tight tracking-tight outline-none placeholder:text-stone-400 md:text-7xl" />
                        <textarea id="note-description" value={description} onChange={(event) => setDescription(event.target.value)} placeholder="Add a short description…" aria-label="Note description" rows={2} className="mt-6 w-full max-w-3xl resize-none bg-transparent text-lg leading-8 text-secondary outline-none placeholder:text-stone-400 md:text-xl" />
                    </header>
                    <div className="mx-auto max-w-4xl border-t border-subtle pt-8"><div id={holderId} /></div>
                </main>
            </section>
        </div>
    )
}