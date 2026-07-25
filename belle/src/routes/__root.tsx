import { useState } from 'react'
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools'
import { AppErrorBoundary } from '../components/ErrorBoundary'
import Sidebar from '../components/Sidebar'

const RootLayout = () => {
  const [collapsed, setCollapsed] = useState(true)

  return (
    <>
      <div className="relative font-popppins font-light flex min-h-screen">
        <aside className={`hidden md:flex flex-col bg-gray-50 p-1.5 rounded-md transition-all duration-200 sticky top-0 self-start h-screen ${collapsed ? 'w-12' : 'w-50'}`}>
          <Sidebar collapsed={collapsed} onToggle={() => setCollapsed((value) => !value)} />
        </aside>
        <div className="hidden md:block flex-1 min-h-screen">
          <AppErrorBoundary>
            <Outlet />
          </AppErrorBoundary>
        </div>
      </div>
      <TanStackRouterDevtools />
    </>
  )
}

export const Route = createRootRoute({ component: RootLayout })