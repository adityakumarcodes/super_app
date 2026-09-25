import { useEffect, useState } from 'react'
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { AppErrorBoundary } from '../components/ErrorBoundary'
import Sidebar from '../components/Sidebar'
import { CartProvider } from '../components/CartContext'

const RootLayout = () => {
  const [collapsed, setCollapsed] = useState(true)

  useEffect(() => {
    const themeColor = localStorage.getItem('belle-theme-color') ?? '#f0d5a6'
    document.documentElement.style.setProperty('--theme-accent', themeColor)
    document.documentElement.dataset.theme = themeColor
  }, [])

  return (
    <CartProvider>
      <div className="relative font-poppins font-light flex min-h-screen">
        <aside className={`flex flex-col bg-gray-50 p-1.5 rounded-md transition-all duration-200 sticky top-0 self-start h-screen ${collapsed ? 'w-12' : 'w-50'}`}>
          <Sidebar collapsed={collapsed} onToggle={() => setCollapsed((value) => !value)} />
        </aside>
        <div className="flex-1 min-h-screen">
          <AppErrorBoundary>
            <Outlet />
          </AppErrorBoundary>
        </div>
      </div>
    </CartProvider>
  )
}

export const Route = createRootRoute({ component: RootLayout })