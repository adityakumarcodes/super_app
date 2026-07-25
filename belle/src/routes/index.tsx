import { createFileRoute } from '@tanstack/react-router'
import WordOfTheDay from '../components/WordOfTheDay'
import About from '../components/About'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  return (
    <div>
      <WordOfTheDay />
      < About />
    </div >
  )
}