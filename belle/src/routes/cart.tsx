import { createFileRoute, Link } from '@tanstack/react-router';
import { ShoppingCart, Trash2 } from 'lucide-react';
import QuantityStepper from '../components/QuantityStepper';
import SurfaceCard from '../components/SurfaceCard';
import { useCart } from '../components/CartContext';

export const Route = createFileRoute('/cart')({
  component: CartPage,
});

function CartPage() {
  const { items, updateQuantity, removeItem } = useCart();
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const deliveryFee = 50;
  const grandTotal = subtotal + deliveryFee;

  return (
    <div className="p-4">
      <h1 className="mb-8 text-5xl font-bodoni text-[#1f1d1b]">Shopping Cart</h1>

      <div className="flex gap-8">
        <div className="flex-1 space-y-4">
          {items.length === 0 && (
            <SurfaceCard className="p-8 text-center">
              <h2 className="text-2xl text-[#1f1d1b]">Your cart is empty</h2>
              <p className="mt-2 text-[#5b5651]">Add a product from the shop to get started.</p>
            </SurfaceCard>
          )}
          {items.map((item) => (
            <SurfaceCard key={item.id} className="flex items-center justify-between p-4">
              <div className="flex items-center gap-4">
                <div className="h-20 w-20 overflow-hidden rounded-[14px] border border-[#2f2d2d] bg-white p-1">
                  <img src={item.image} alt={item.name} className="h-full w-full rounded-[10px] object-cover" />
                </div>

                <div>
                  <div className="text-[1.12rem] font-medium text-[#221f1e]">{item.name}</div>
                  <div className="text-[#5d5853]">{item.size}</div>
                </div>
              </div>

              <div className="flex items-center gap-6">
                <QuantityStepper
                  value={item.quantity}
                  onChange={(quantity) => updateQuantity(item.id, quantity)}
                />

                <div className="w-20 text-right text-[1.05rem] font-medium text-[#1f1d1b]">₹ {item.price}</div>

                <button
                  type="button"
                  onClick={() => removeItem(item.id)}
                  className="flex h-9 w-9 items-center justify-center rounded-full border border-[#2f2d2d] text-[#1f1d1b]"
                >
                  <Trash2 size={15} />
                </button>
              </div>
            </SurfaceCard>
          ))}
        </div>

        <SurfaceCard className="w-[340px] p-5">
          <h2 className="mb-5 text-[1.7rem] font-medium text-[#1f1d1b]">Order Summary</h2>

          <div className="space-y-3 text-[1.05rem]">
            <div className="flex items-center justify-between">
              <span className="text-[#5b5651]">Subtotal</span>
              <span className="font-medium text-[#1f1d1b]">₹ {subtotal}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-[#5b5651]">Delivery Fee</span>
              <span className="font-medium text-[#1f1d1b]">₹ {deliveryFee}</span>
            </div>
            <div className="mt-3 border-t divider pt-3">
              <div className="flex items-center justify-between text-[1.2rem] font-medium text-[#1f1d1b]">
                <span>Grand Total</span>
                <span>₹ {grandTotal}</span>
              </div>
            </div>
          </div>

          <div className="mt-6">
            <div className="mb-3 text-[0.76rem] font-medium uppercase tracking-[0.18em] text-[#5b5651]">Delivery option</div>
            <div className="flex rounded-full border border-[#2f2d2d] bg-[#f3efe8] p-1">
              <button className="flex-1 rounded-full theme-accent-bg px-4 py-2 font-medium text-[#1f1d1b]">Standard Delivery</button>
              <button className="flex-1 rounded-full px-4 py-2 text-[#5b5651]">Store Pickup</button>
            </div>
          </div>

          <Link
            to="/shop"
            className="mt-6 flex w-full items-center justify-center gap-2 rounded-full border border-[#2f2d2d] theme-accent-bg px-5 py-3 text-[1.08rem] font-medium text-[#1f1d1b]"
          >
            <ShoppingCart size={18} />
            Proceed to Checkout
          </Link>
        </SurfaceCard>
      </div>
    </div>
  );
}
