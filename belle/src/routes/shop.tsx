import { createFileRoute, Outlet, useNavigate } from '@tanstack/react-router'
import { useState } from 'react';
import { Baby, Carrot, Monitor, Plane, Rose, Shirt, Sparkles, Tags, Utensils } from 'lucide-react';

export const Route = createFileRoute('/shop')({
  component: RouteComponent,
})

function RouteComponent() {
  const [menu, setMenu] = useState<string | null>(null);
  const navigate = useNavigate();
  const categories = [
    { label: 'Electronics', icon: Monitor },
    { label: 'Grocery', icon: Carrot },
    { label: 'Gifts & Flowers', icon: Rose },
    { label: 'Beauty', icon: Sparkles },
    { label: 'Fashion', icon: Shirt },
    { label: 'Baby', icon: Baby },
    { label: 'Brands', icon: Tags },
    { label: 'Food', icon: Utensils },
    { label: 'Travel', icon: Plane },
  ] as const;

  const selectCategory = (item: string) => {
    setMenu(item);
    const category = item.toLowerCase().replaceAll(' & ', '-and-').replaceAll(' ', '-');
    navigate({ to: '/shop/$category', params: { category } });
  };

  return <div className="p-4">
    <div className="text-center my-8">
      <h1 className="font-bodoni text-6xl">Shop</h1>
    </div>
    <div>
      <div className="flex flex-wrap justify-center gap-6 my-10">
        {categories.map(({ label, icon: Icon }) => (
          <button
            key={label}
            onClick={() => selectCategory(label)}
            className={menu === label ? 'flex items-center gap-2 bg-orange-200 py-2 px-4 rounded-full border-2' : 'flex items-center gap-2 border-2 py-2 px-4 rounded-full'}
          >
            <Icon strokeWidth={1.5} />
            {label}
          </button>
        ))}
      </div>
      <Outlet />
    </div>
  </div>
}
