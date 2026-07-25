import { createFileRoute, Outlet, useLocation } from '@tanstack/react-router';
import NoteList from '../components/NoteList';

export const Route = createFileRoute('/notes')({
  component: RouteComponent,
});

function RouteComponent() {
  const location = useLocation();

  if (location.pathname !== '/notes') {
    return <Outlet />;
  }

  return (
    <div className="p-4">
      <div className="text-center my-8">
        <h1 className="font-bodoni text-6xl">Notes</h1>
      </div>
      <NoteList />
    </div>
  );
}
