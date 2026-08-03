import { createFileRoute } from '@tanstack/react-router'
import NoteDetails from '../components/NoteDetails'
import notes from '../../assets/data/notes.json'

export const Route = createFileRoute('/notes/$noteId')({
  component: RouteComponent,
  validateSearch: (search: Record<string, unknown>) => ({
    title: typeof search.title === 'string' ? search.title : undefined,
    description:
      typeof search.description === 'string' ? search.description : undefined,
  }),
})

function RouteComponent() {
  const { noteId } = Route.useParams()
  const note = notes.find((item) => String(item.id) === noteId)

  if (!note) {
    return <div className='p-8'>Note not found.</div>
  }

  return (
    <div className='flex flex-col h-screen overflow-y-scroll'>
      <div className='m-4 p-2'>
        <p className='text-6xl m-4 font-bodoni leading-normal'>{note.title || 'Untitled note'}</p>
        <p>{note.description || 'No description provided.'}</p>
        <NoteDetails data={note.long_desc} imageUrl={note.imageUrl} />
      </div>
    </div>
  )
}
