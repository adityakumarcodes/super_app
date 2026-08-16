import { createFileRoute } from '@tanstack/react-router'
import WordOfTheDay from '../components/WordOfTheDay'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  return (
    <div>
      <WordOfTheDay />
    </div >
  )
}