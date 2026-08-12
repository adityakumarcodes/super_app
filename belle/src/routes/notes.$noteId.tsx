import { createFileRoute } from '@tanstack/react-router'
import NoteDetails from '../components/NoteDetails'
import useFetchQuery from '../utils/useFetchQuery'

type NoteBlock = {
  id: number | string
  blockKey?: string | null
  type: string
  data: Record<string, any>
}

type Note = {
  id: number | string
  title?: string
  description?: string
  imageUrl?: string
  blocks?: NoteBlock[]
  editorVersion?: string | null
}

export const Route = createFileRoute('/notes/$noteId')({
  component: RouteComponent,
  validateSearch: (search: Record<string, unknown>) => ({
    title: typeof search.title === 'string' ? search.title : undefined,
  }),
})

function RouteComponent() {
  const { noteId } = Route.useParams()
  const BASE = (import.meta.env.VITE_API_BASE as string) || 'http://localhost:3000/api'
  const { data: note, isLoading } = useFetchQuery<Note>({ queryKey: ['note', noteId], queryLink: `${BASE}/notes/${noteId}`, queryOptions: { enabled: !!noteId } })

  if (isLoading) return <div className='p-8'>Loading...</div>

  if (!note) {
    return <div className='p-8'>Note not found.</div>
  }

  const editorData = {
    time: Date.now(),
    blocks: (note.blocks || []).map((b: NoteBlock) => ({
      id: b.blockKey ?? String(b.id),
      type: b.type,
      data: b.data,
    })),
    version: note.editorVersion ?? undefined,
  }

  return (
    <div className='flex flex-col h-screen overflow-y-scroll'>
      <div className="mx-auto w-full max-w-5xl px-4 py-10 md:px-8">
        <header className="mb-12">
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
                className="
        h-75 w-full object-cover
        transition-transform duration-700 ease-out
        group-hover:scale-105
        md:h-112.5
      "
              />
            </div>
          )}
        </header>

        <main className="mx-auto max-w-4xl">
          <NoteDetails data={editorData} />
        </main>
      </div>
    </div>
  )
}
