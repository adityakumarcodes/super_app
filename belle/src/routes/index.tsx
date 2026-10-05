import { createFileRoute } from '@tanstack/react-router'
import { ToolCase, X } from 'lucide-react'
import { useState } from 'react'
import IconButton from '../components/IconButton'
import TodoWidget from '../components/Todo'
import WordOfTheDay from '../components/WordOfTheDay'
import WeatherWidget from '../components/Weather'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  const [toolsOpen, setToolsOpen] = useState(false)

  return (
    <div className="surface-body">
      <WordOfTheDay />

      {/* Floating Tools Button */}
      <div className="fixed bottom-6 right-6 z-40">
        <IconButton
          icon={ToolCase}
          label="Widgets"
          onClick={() => setToolsOpen(true)}
        />
      </div>

      {/* Tools Sidebar */}
      {toolsOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-40 bg-black/20"
            onClick={() => setToolsOpen(false)}
          />

          {/* Sidebar */}
          <aside
            className="
              fixed right-0 top-0 z-50
              h-screen w-1/3
              overflow-y-auto
              border-l-2 border-strong
              surface-raised
              p-5
            "
          >
            <div className="mb-6 flex justify-end">
              <IconButton
                icon={X}
                label="Close"
                onClick={() => setToolsOpen(false)}
              />
            </div>

            <div className="space-y-4">
              <TodoWidget />
              <WeatherWidget place="Noida" />
            </div>
          </aside>
        </>
      )}
    </div>
  )
}