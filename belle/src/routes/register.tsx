import { createFileRoute } from '@tanstack/react-router';
import Register from '../components/Register';
import { redirectIfAuthenticated } from '../utils/redirectIfAuthenticated';

export const Route = createFileRoute('/register')({
  beforeLoad: redirectIfAuthenticated,
  component: Register,
});