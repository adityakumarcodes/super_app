import { createFileRoute } from '@tanstack/react-router'
import { AlarmClock, CloudSun, HeartHandshake, ListTodo } from 'lucide-react'
import { useState, type ElementType } from 'react'
import IconButton from '../components/IconButton'
import TodoWidget from '../components/Todo'
import WordOfTheDay from '../components/WordOfTheDay'
import WeatherWidget from '../components/Weather'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  type HomeWidget = 'Weather' | 'Health' | 'Alarm' | 'Todo'
  const [activeWidget, setActiveWidget] = useState<HomeWidget>('Weather')
  const actions = [
    { label: 'Weather', icon: CloudSun },
    { label: 'Health', icon: HeartHandshake },
    { label: 'Alarm', icon: AlarmClock },
    { label: 'Todo', icon: ListTodo },
  ] as const

  const placeholders: Record<'Health' | 'Alarm', { icon: ElementType; eyebrow: string; title: string; description: string }> = {
    Health: { icon: HeartHandshake, eyebrow: 'Your wellbeing', title: 'Health check-in', description: 'Health tracking can live here when you are ready to connect your habits and goals.' },
    Alarm: { icon: AlarmClock, eyebrow: 'Plan your time', title: 'No alarms yet', description: 'Create a reminder flow here when alarm scheduling is connected.' },
  }

  return (
    <div>
      <WordOfTheDay />
      <div className="flex flex-wrap justify-center gap-3 p-4">
        {actions.map((action) => <IconButton key={action.label} {...action} active={activeWidget === action.label} onClick={() => setActiveWidget(action.label)} />)}
      </div>
      {activeWidget === 'Weather' && <WeatherWidget place="Noida" />}
      {activeWidget === 'Todo' && <TodoWidget />}
      {(activeWidget === 'Health' || activeWidget === 'Alarm') && <HomePlaceholder {...placeholders[activeWidget]} />}
    </div >
  )
}

function HomePlaceholder({ icon: Icon, eyebrow, title, description }: { icon: ElementType; eyebrow: string; title: string; description: string }) {
  return (
    <section className="surface-card mx-auto max-w-5xl p-6 text-center sm:p-10">
      <span className="theme-accent-soft mx-auto flex h-12 w-12 items-center justify-center rounded-full border border-strong"><Icon size={23} /></span>
      <p className="mt-5 text-sm text-secondary">{eyebrow}</p>
      <h2 className="mt-1 font-bodoni text-4xl">{title}</h2>
      <p className="mx-auto mt-3 max-w-md text-secondary">{description}</p>
    </section>
  )
}
