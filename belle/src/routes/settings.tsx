import { createFileRoute } from '@tanstack/react-router'
import { useEffect, useState } from 'react';
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
            className={menu === item ? 'theme-accent-bg py-2 px-4 rounded-full border-2' : 'border-2 py-2 px-4 rounded-full'}
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
  const [themeColor, setThemeColor] = useState(() => localStorage.getItem('belle-theme-color') ?? '#f0d5a6');
  const colors = [
    { name: 'Peach', value: '#f0d5a6' },
    { name: 'Sage', value: '#b9cdb2' },
    { name: 'Sky', value: '#b9d7e5' },
    { name: 'Rose', value: '#e7b8b4' },
    { name: 'Lavender', value: '#c9bfda' },
  ];

  useEffect(() => {
    document.documentElement.style.setProperty('--theme-accent', themeColor);
    document.documentElement.dataset.theme = themeColor;
    localStorage.setItem('belle-theme-color', themeColor);
  }, [themeColor]);

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

      <div className="flex items-center justify-between gap-6 border-b p-5">
        <div>
          <p className="font-medium">Accent color</p>
          <p className="text-sm text-slate-500">
            Choose a color for highlights across Bellee.
          </p>
        </div>

        <div className="flex items-center gap-3" role="radiogroup" aria-label="Accent color">
          {colors.map((color) => (
            <button
              key={color.name}
              type="button"
              title={color.name}
              aria-label={`${color.name} accent color`}
              aria-pressed={themeColor === color.value}
              onClick={() => setThemeColor(color.value)}
              className={`h-8 w-8 rounded-full border-2 transition ${themeColor === color.value ? 'border-black ring-2 ring-black ring-offset-2' : 'border-gray-400'}`}
              style={{ backgroundColor: color.value }}
            />
          ))}
        </div>
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
              ? 'theme-accent-bg text-black'
              : 'text-slate-500 hover:bg-slate-100'
              }`}
          >
            List
          </button>

          <button
            type="button"
            onClick={() => setNotesView('tree')}
            className={`rounded-md px-4 py-2 text-sm font-medium transition ${notesView === 'tree'
              ? 'theme-accent-bg text-black'
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
          className="h-5 w-5 theme-accent-control"
        />
      </div>
    </div>
  );
};

export default Appearance;