import { createFileRoute, Outlet, useMatches } from '@tanstack/react-router';
import ProductList from '../components/ProductList';

export const Route = createFileRoute('/shop/$category')({
    component: CategoryPage,
});

function CategoryPage() {
    const { category } = Route.useParams();
    const matches = useMatches();
    const isProductDetailRoute = matches.some((match) => match.routeId === '/shop/$category/$productId');

    if (isProductDetailRoute) return <Outlet />;

    if (category === 'grocery') return <ProductList />;

    return <div className="py-8 text-center text-gray-500">No products available for this category.</div>;
}