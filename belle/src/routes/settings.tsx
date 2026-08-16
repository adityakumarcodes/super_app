import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react';
import About from '../components/About';
import Profile from '../components/Profile';

export const Route = createFileRoute('/settings')({
  component: RouteComponent,
})

function RouteComponent() {
  const [menu, setMenu] = useState('Profile');
  return <div className="p-4">
    <div className=" my-8">
      <h1 className="font-bodoni text-6xl">Settings</h1>
    </div>
    <div>
      <div className="flex flex-wrap justify-start gap-6 my-10">
        {(['Profile', 'Appearance', 'About'] as const).map((item) => (
          <button
            key={item}
            onClick={() => setMenu(item)}
            className={menu === item ? 'bg-orange-200 py-2 px-4 rounded-full border-2' : 'border-2 py-2 px-4 rounded-full'}
          >
            {item}
          </button>
        ))}
      </div>
      <div>
        {menu === 'Profile' && <Profile />}
        {menu === 'Appearance' && <Appearance />}
        {menu === 'About' && <About />}
      </div>
    </div>
  </div >
}


const Appearance = () => {
  const [notesView, setNotesView] = useState<'list' | 'tree'>('list');

  return (
    <div className="m-6 overflow-hidden rounded-2xl border-2 border-black bg-white">
      {/* Theme */}
      <div className="flex items-center justify-between border-b p-5 gap-6">
        <div>
          <p className="font-medium">Theme</p>
          <p className="text-sm text-slate-500">
            Choose your theme.
          </p>
        </div>

        <select className="rounded-lg border-2 border-black bg-white px-3 py-2 text-sm">
          <option>System</option>
          <option>Light</option>
          <option>Dark</option>
        </select>
      </div>

      {/* Notes View */}
      <div className="flex items-center justify-between gap-6 border-b p-5">
        <div>
          <p className="font-medium">Notes view</p>
          <p className="text-sm text-slate-500">
            Choose how your notes are displayed.
          </p>
        </div>

        <div className="flex rounded-lg border-2">
          <button
            type="button"
            onClick={() => setNotesView('list')}
            className={`rounded-md px-4 py-2 text-sm font-medium transition ${notesView === 'list'
              ? 'bg-orange-200 text-black'
              : 'text-slate-500 hover:bg-slate-100'
              }`}
          >
            List
          </button>

          <button
            type="button"
            onClick={() => setNotesView('tree')}
            className={`rounded-md px-4 py-2 text-sm font-medium transition ${notesView === 'tree'
              ? 'bg-orange-200 text-black'
              : 'text-slate-500 hover:bg-slate-100'
              }`}
          >
            Tree
          </button>
        </div>
      </div>

      {/* Compact mode */}
      <div className="flex items-center justify-between gap-6 p-5">
        <div>
          <p className="font-medium">
            Sidebar style
          </p>

          <p className="text-sm text-slate-500">
            Reduce spacing throughout Bellee.
          </p>
        </div>

        <input
          type="checkbox"
          className="h-5 w-5 accent-orange-400"
        />
      </div>
    </div>
  );
};

export default Appearance;