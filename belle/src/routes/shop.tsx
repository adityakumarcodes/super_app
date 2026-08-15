import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react';
import ProductList from '../components/ProductList';

export const Route = createFileRoute('/shop')({
  component: RouteComponent,
})

function RouteComponent() {
  const [menu, setMenu] = useState('Grocery');
  return <div className="p-4">
    <div className="text-center my-8">
      <h1 className="font-bodoni text-6xl">Shop</h1>
    </div>
    <div>
      <div className="flex flex-wrap justify-center gap-6 my-10">
        {(['Electronics', 'Grocery', 'Gifts & Flowers', 'Beauty', 'Fashion', 'Baby', 'Brands'] as const).map((item) => (
          <button
            key={item}
            onClick={() => setMenu(item)}
            className={menu === item ? 'bg-orange-200 py-2 px-4 rounded-full border-2' : 'border-2 py-2 px-4 rounded-full'}
          >
            {item}
          </button>
        ))}
      </div>
      <ProductList />
    </div>
  </div>
}
