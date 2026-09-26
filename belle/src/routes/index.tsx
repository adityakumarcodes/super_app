import { createFileRoute } from '@tanstack/react-router'
import { CloudSun, ListTodo } from 'lucide-react'
import { useState } from 'react'
import IconButton from '../components/IconButton'
import TodoWidget from '../components/Todo'
import WordOfTheDay from '../components/WordOfTheDay'
import WeatherWidget from '../components/Weather'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  type HomeWidget = 'Weather' | 'Todo'
  const [activeWidget, setActiveWidget] = useState<HomeWidget>('Weather')
  const actions = [
    { label: 'Weather', icon: CloudSun },
    { label: 'Todo', icon: ListTodo },
  ] as const

  return (
    <div>
      <WordOfTheDay />
      <div className="flex flex-wrap justify-center gap-3 p-4">
        {actions.map((action) => <IconButton key={action.label} {...action} active={activeWidget === action.label} onClick={() => setActiveWidget(action.label)} />)}
      </div>
      {activeWidget === 'Weather' && <WeatherWidget place="Noida" />}
      {activeWidget === 'Todo' && <TodoWidget />}
    </div >
  )
}
