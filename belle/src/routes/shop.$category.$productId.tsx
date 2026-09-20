import { createFileRoute, useNavigate } from '@tanstack/react-router';
import { ShieldCheck, ShoppingCart, Star } from 'lucide-react';
import { useState } from 'react';
import products from '../../assets/data/shops.json';
import QuantityStepper from '../components/QuantityStepper';
import { useCart } from '../components/CartContext';

export const Route = createFileRoute('/shop/$category/$productId')({
  component: ProductDetailsPage,
});

function ProductDetailsPage() {
  const { category, productId } = Route.useParams();
  const [quantity, setQuantity] = useState(1);
  const navigate = useNavigate();
  const { addItem } = useCart();
  const product = products.find((item) => String(item.id) === productId) ?? {
    id: 1,
    name: 'Organic Heirloom Tomatoes',
    price: 120,
    image: 'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/tomato.jpg',
    category: 'vegetables',
  };

  const gallery = [
    product.image,
    'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/tomato.jpg',
    'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/cauliflower.jpg',
    'https://res.cloudinary.com/sivadass/image/upload/v1493620046/dummy-products/beans.jpg',
  ];

  return (
    <div className="p-4">
      <div className="mb-4 text-sm text-gray-500">
        <span>Shop</span>
        <span className="mx-2">›</span>
        <span className="capitalize">{category}</span>
        <span className="mx-2">›</span>
        <span>{product.name}</span>
      </div>

      <div className="flex gap-8">
        <div className="flex-1">
          <div className="rounded-[20px] border border-[#2f2d2d] bg-[#f2f0ed] p-3">
            <img
              src={product.image}
              alt={product.name}
              className="h-[430px] w-full rounded-[16px] object-cover"
            />
          </div>

          <div className="mt-5 flex gap-4">
            {gallery.map((image, index) => (
              <div
                key={`${image}-${index}`}
                className={`h-20 w-20 overflow-hidden rounded-[12px] border ${index === 0 ? 'border-[#2f2d2d] bg-white' : 'border-[#c9c3bd]'
                  }`}
              >
                <img src={image} alt={`${product.name} thumbnail ${index + 1}`} className="h-full w-full object-cover" />
              </div>
            ))}
          </div>
        </div>

        <div className="w-[420px]">
          <span className="inline-block rounded-full border border-[#2f2d2d] theme-accent-bg px-3 py-1 text-[0.7rem] font-medium uppercase tracking-[0.18em] text-[#2f2d2d]">
            Organic fresh
          </span>

          <h2 className="mt-5 text-5xl leading-[1.08] tracking-[-0.04em] text-[#1f1d1b]">
            {product.name}
          </h2>

          <div className="mt-3 text-[1.05rem] text-[#4d4743]">
            500g • Source: Sunny Valley Farm
          </div>

          <div className="mt-8 flex items-center justify-between gap-4 border-b divider pb-6">
            <div className="text-4xl font-medium text-[#1f1d1b]">₹ {product.price}</div>
            <div className="flex items-center gap-2 text-[#4d4743]">
              <Star className="fill-[#1f1d1b] text-[#1f1d1b]" size={16} />
              <span>4.9</span>
              <span className="text-secondary">(118 reviews)</span>
            </div>
          </div>

          <div className="mt-6">
            <div className="mb-3 text-[0.76rem] font-medium uppercase tracking-[0.18em] text-[#5f5955]">
              Product description
            </div>
            <p className="text-lg leading-8 text-[#2d2a29]">
              Juicy, heirloom variety tomatoes with vibrant colors and rich flavor profiles. Perfect for classic salads,
              caprese, baking, or fresh pasta sauces. Grown without artificial fertilizers.
            </p>
          </div>

          <div className="mt-8 flex items-center justify-between gap-4">
            <div className="text-[1.2rem] font-medium text-[#1f1d1b]">Select Quantity</div>
            <QuantityStepper value={quantity} onChange={setQuantity} />
          </div>

          <div className="mt-8 rounded-[18px] border border-[#2f2d2d] bg-[#f5f0ea] p-4">
            <div className="flex items-center gap-3 text-[1.03rem] font-medium text-[#2a2726]">
              <ShieldCheck size={18} />
              <span>Delivery Estimate to 400001</span>
            </div>
            <div className="mt-2 text-[#625d5b]">Tomorrow, Wednesday • Free shipping on orders over ₹500</div>
          </div>

          <div className="mt-6 space-y-3">
            <button
              type="button"
              onClick={() => {
                addItem(product, quantity);
                navigate({ to: '/cart' });
              }}
              className="flex w-full items-center justify-center gap-2 rounded-full border border-[#2f2d2d] theme-accent-bg px-5 py-3 text-[1.08rem] font-medium text-[#1f1d1b]"
            >
              <ShoppingCart size={18} />
              Add to shopping cart
            </button>

            <button className="flex w-full items-center justify-center rounded-full border border-[#2f2d2d] bg-transparent px-5 py-3 text-[1.08rem] text-[#1f1d1b]">
              Save to wishlist
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
