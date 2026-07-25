import { createFileRoute } from '@tanstack/react-router'

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
  const { title, description } = Route.useSearch()

  return (
    <div className='flex flex-col h-screen overflow-y-scroll'>
      <div className='m-4 p-2'>
        <p>{noteId}</p>

        <p className='text-6xl m-4 font-bodoni leading-normal'>{title ?? 'Untitled note'}</p>
        <p>{description ?? 'No description provided.'}</p>
      </div>
    </div>
  )
}
