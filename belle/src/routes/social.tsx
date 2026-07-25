import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react';

export const Route = createFileRoute('/social')({
  component: RouteComponent,
})

function RouteComponent() {
  const [menu, setMenu] = useState('My Feed');

  return <div className="p-4">
    <div className="text-center my-8">
      <h1 className="font-bodoni text-6xl">Social</h1>
    </div>
    <div>
      <div className="flex flex-wrap justify-center gap-6 my-10">
        {(['My Feed', 'Jobs', 'Communities'] as const).map((item) => (
          <button
            key={item}
            onClick={() => setMenu(item)}
            className={menu === item ? 'bg-orange-200 py-2 px-4 rounded-full border-2' : 'border-2 py-2 px-4 rounded-full'}
          >
            {item}
          </button>
        ))}
      </div>
      <p>Content</p>
    </div>
  </div >
}
