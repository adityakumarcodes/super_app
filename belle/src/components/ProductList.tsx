import { Link } from '@tanstack/react-router';
import { ShoppingCart } from 'lucide-react';
import products from "../../assets/data/shops.json";
import { useCart } from './CartContext';

export default function ProductList() {
    const { items, addItem } = useCart();
    const cartCount = items.reduce((total, item) => total + item.quantity, 0);

    return (
        <div className="p-2">
            <div className="mb-4">
                <h2 className="text-3xl text-primary">Grocery</h2>
            </div>

            <div className="grid grid-cols-2 gap-4 md:grid-cols-3 xl:grid-cols-4">
                {products.map((product) => (
                    <article
                        key={product.id}
                        className="surface-card flex cursor-pointer flex-col overflow-hidden transition hover:-translate-y-0.5 hover:shadow-sm"
                    >
                        <Link
                            to="/shop/$category/$productId"
                            params={{ category: 'grocery', productId: String(product.id) }}
                            className="block"
                        >
                            <img
                                src={product.image}
                                alt={product.name}
                                loading="lazy"
                                className="h-full w-full rounded-[12px] object-contain"
                            />
                        </Link>
                        <div className="flex flex-1 flex-col border-t divider p-4">
                            <div className="flex items-start justify-between gap-3">
                                <h6 className="text-primary min-w-0 flex-1 text-lg leading-tight">{product.name}</h6>
                                <div className="text-primary flex shrink-0 items-baseline gap-1">
                                    <span className="text-secondary text-sm font-medium">₹</span>
                                    <span className="text-xl font-semibold tracking-tight">{product.price}</span>
                                </div>
                            </div>
                            <button
                                type="button"
                                onClick={(event) => {
                                    event.preventDefault();
                                    event.stopPropagation();
                                    addItem(product);
                                }}
                                className="control-pill mt-4 inline-flex w-full items-center justify-center gap-2 border border-strong px-3 py-2 text-sm font-medium transition theme-accent-bg"
                            >
                                <ShoppingCart size={16} />
                                Add to cart
                            </button>
                        </div>
                    </article>
                ))}
            </div>

            <Link
                to="/cart"
                className="surface-card fixed bottom-4 left-1/2 z-20 flex w-[calc(100%-2rem)] max-w-md -translate-x-1/2 items-center justify-between gap-4 p-3 shadow-lg"
            >
                <span className="flex items-center gap-2 text-sm font-medium text-primary">
                    <ShoppingCart size={18} />
                    <span>{cartCount} {cartCount === 1 ? 'item' : 'items'} in cart</span>
                </span>
                <span className="theme-accent-bg control-pill px-4 py-2 text-sm font-medium text-primary">
                    View cart
                </span>
            </Link>
        </div>
    );
}