import { useState } from 'react';
import { Link, useNavigate } from '@tanstack/react-router';
import { authClient } from '../utils/auth-client';

const Login = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleLogin = async (event: React.FormEvent) => {
        event.preventDefault();

        setError('');
        setLoading(true);

        const { error } = await authClient.signIn.email({
            email,
            password,
        });

        setLoading(false);

        if (error) {
            setError(error.message ?? 'Something went wrong.');
            return;
        }

        // Navigate after successful login
        navigate({ to: '/' });
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-slate-50 p-6">
            <div className="w-full max-w-md">
                <div className="mb-10 text-center">
                    <h1 className="font-bodoni text-6xl text-black">
                        Welcome back
                    </h1>
                </div>

                <form
                    onSubmit={handleLogin}
                    className="rounded-2xl border-2 border-black bg-white p-6"
                >
                    <div className="space-y-5">
                        <div>
                            <label
                                htmlFor="email"
                                className="text-sm font-medium text-slate-900"
                            >
                                Email
                            </label>

                            <input
                                id="email"
                                type="email"
                                value={email}
                                onChange={(event) =>
                                    setEmail(event.target.value)
                                }
                                placeholder="you@example.com"
                                required
                                className="mt-2 w-full rounded-lg border-2 border-black bg-white px-3 py-2.5 text-sm outline-none transition"
                            />
                        </div>

                        <div>
                            <label
                                htmlFor="password"
                                className="text-sm font-medium text-slate-900"
                            >
                                Password
                            </label>

                            <input
                                id="password"
                                type="password"
                                value={password}
                                onChange={(event) =>
                                    setPassword(event.target.value)
                                }
                                placeholder="••••••••"
                                required
                                className="mt-2 w-full rounded-lg border-2 border-black bg-white px-3 py-2.5 text-sm outline-none transition "
                            />
                        </div>

                        {error && (
                            <div className="rounded-lg border-2 border-black bg-red-50 p-3 text-sm text-red-700">
                                {error}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full rounded-lg border-2 border-black bg-orange-400 px-4 py-2.5 text-sm font-semibold text-black transition hover:bg-orange-300 disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            {loading ? 'Signing in...' : 'Sign in'}
                        </button>
                    </div>

                    <div className="mt-6 border-t border-slate-200 pt-5 text-center text-sm text-slate-500">
                        Don't have an account?{' '}
                        <Link
                            to="/register"
                            className="font-medium text-black underline underline-offset-4"
                        >
                            Create one
                        </Link>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default Login;