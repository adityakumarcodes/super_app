import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/chat')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div className="p-4">
    <div className="text-center my-8">
      <h1 className="font-bodoni text-6xl">Chat</h1>
    </div>
    <p>Content</p>
  </div>
}
