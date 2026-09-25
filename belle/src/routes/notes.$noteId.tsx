import { createFileRoute, Link, useNavigate } from '@tanstack/react-router'
import { ArrowLeft, Pencil, Trash2, X } from 'lucide-react'
import { useMemo, useState } from 'react'
import NoteDetails from '../components/NoteDetails'
import NoteComposerModal from '../components/NoteCompose'
import useFetchQuery from '../utils/useFetchQuery'
import Spinner from '../components/Spinner'
import { deleteLocalNote, getDrafts, getOverride, saveNote, type Note } from '../utils/noteDrafts'

export const Route = createFileRoute('/notes/$noteId')({
  component: RouteComponent,
})

function RouteComponent() {
  const { noteId } = Route.useParams()
  const navigate = useNavigate()
  const [isEditorOpen, setIsEditorOpen] = useState(false)
  const [isDeleteOpen, setIsDeleteOpen] = useState(false)
  const [localVersion, setLocalVersion] = useState<Note | undefined>(() => getDrafts().find((draft) => String(draft.id) === noteId) ?? getOverride(noteId))
  const BASE = (import.meta.env.VITE_API_BASE as string) || 'http://localhost:3000/api'
  const { data: fetchedNote, isLoading } = useFetchQuery<Note>({ queryKey: ['note', noteId], queryLink: `${BASE}/notes/${noteId}`, queryOptions: { enabled: !!noteId && !noteId.startsWith('draft-') } })
  const note = useMemo(() => {
    if (localVersion?.isLocal) return localVersion
    return localVersion ? { ...fetchedNote, ...localVersion, blocks: localVersion.blocks ?? fetchedNote?.blocks } : fetchedNote
  }, [fetchedNote, localVersion])

  if (isLoading && !note) return <Spinner />

  if (!note) {
    return <div className='p-8'>Note not found.</div>
  }

  const editorData = {
    time: Date.now(),
    blocks: (note.blocks || []).map((b) => ({
      id: b.blockKey ?? String(b.id),
      type: b.type,
      data: b.data,
    })),
    version: note.editorVersion ?? undefined,
  }

  const saveLocalChange = (updatedNote: Note) => {
    const nextNote = { ...updatedNote, isLocal: note.isLocal }
    saveNote(nextNote)
    setLocalVersion(nextNote)
    setIsEditorOpen(false)
  }

  const removeNote = () => {
    deleteLocalNote(noteId)
    void navigate({ to: '/notes' })
  }

  return (
    <div className='flex min-h-screen flex-col overflow-y-auto'>
      <div className="mx-auto w-full max-w-5xl px-4 py-10 md:px-8">
        <header className="mb-12">
          <div className="mb-8 flex items-center justify-between gap-3">
            <Link to="/notes" className="control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 hover-surface-card"><ArrowLeft size={18} />All notes</Link>
            <div className="flex gap-2">
              <button type="button" onClick={() => setIsEditorOpen(true)} className="control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 hover-surface-card"><Pencil size={17} />Edit</button>
              <button type="button" onClick={() => setIsDeleteOpen(true)} className="control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 text-red-700 hover:bg-red-50" aria-label="Delete note"><Trash2 size={17} /></button>
            </div>
          </div>
          {localVersion && <p className="theme-accent-soft mb-6 rounded-xl border border-strong px-4 py-3 text-sm">This version is saved locally in this browser. Connect the note write API to sync it everywhere.</p>}
          <div className="max-w-4xl">
            <h1 className="font-bodoni text-5xl leading-tight tracking-tight md:text-7xl">
              {note.title || "Untitled note"}
            </h1>

            <p className="mt-6 max-w-3xl text-lg leading-8 text-gray-500 md:text-xl">
              {note.description || "No description provided."}
            </p>
          </div>

          {note.imageUrl && (
            <div className="group mt-8 overflow-hidden rounded-4xl">
              <img
                src={note.imageUrl}
                alt={note.title || "Note cover"}
                className="h-75 w-full object-cover transition-transform duration-700 ease-out group-hover:scale-105 md:h-112.5" />
            </div>
          )}
        </header>

        <main className="mx-auto max-w-4xl">
          <NoteDetails data={editorData} />
        </main>
      </div>
      {isEditorOpen && <NoteComposerModal note={note} onClose={() => setIsEditorOpen(false)} onSave={saveLocalChange} />}
      {isDeleteOpen && <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 p-5 backdrop-blur-sm" role="dialog" aria-modal="true" aria-label="Delete note">
        <div className="surface-body w-full max-w-md p-6 shadow-2xl">
          <div className="flex items-start justify-between"><div><p className="text-sm text-secondary">This cannot be undone</p><h2 className="mt-1 text-3xl">Delete this note?</h2></div><button type="button" onClick={() => setIsDeleteOpen(false)} aria-label="Close confirmation"><X /></button></div>
          <p className="mt-3 text-secondary">{note.isLocal ? 'This local draft will be removed from this browser.' : 'The local version will be removed. The server copy remains until delete is connected to the API.'}</p>
          <div className="mt-6 flex justify-end gap-3"><button type="button" onClick={() => setIsDeleteOpen(false)} className="control-pill border border-strong px-4 py-2">Keep note</button><button type="button" onClick={removeNote} className="control-pill border border-red-800 bg-red-700 px-4 py-2 text-white">Delete</button></div>
        </div>
      </div>}
    </div>
  )
}