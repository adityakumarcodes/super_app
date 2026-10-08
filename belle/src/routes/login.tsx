import { createFileRoute } from '@tanstack/react-router';
import Login from '../components/Login';
import { redirectIfAuthenticated } from '../utils/redirectIfAuthenticated';

export const Route = createFileRoute('/login')({
  // send authenticated users trying to access login to /
  beforeLoad:redirectIfAuthenticated,
  component: Login,
});