import { createFileRoute } from '@tanstack/react-router'
import { AlarmClock, CloudSun, HeartHandshake, ListTodo } from 'lucide-react'
import IconButton from '../components/IconButton'
import WordOfTheDay from '../components/WordOfTheDay'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  const actions = [
    { label: 'Weather', icon: CloudSun },
    { label: 'Health', icon: HeartHandshake },
    { label: 'Alarm', icon: AlarmClock },
    { label: 'Todo', icon: ListTodo },
  ]

  return (
    <div>
      <WordOfTheDay />
      <div className="flex justify-center gap-4 p-4">
        {actions.map((action) => <IconButton key={action.label} {...action} />)}
      </div>
    </div >
  )
}