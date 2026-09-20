import { useState } from 'react';
import { Link, useNavigate } from '@tanstack/react-router';
import { authClient } from '../utils/auth-client';

const Register = () => {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleRegister = async (event: React.FormEvent) => {
        event.preventDefault();

        setError('');
        setLoading(true);

        const { error } = await authClient.signUp.email({
            name,
            email,
            password,
        });

        setLoading(false);

        if (error) {
            setError(error.message ?? 'Something went wrong.');
            return;
        }

        navigate({ to: '/' });
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-slate-50 p-6">
            <div className="w-full max-w-md">
                <div className="mb-10 text-center">
                    <h1 className="font-bodoni text-6xl text-black">
                        Create account
                    </h1>


                </div>

                <form
                    onSubmit={handleRegister}
                    className="rounded-2xl border-2 border-black bg-white p-6"
                >
                    <div className="space-y-5">
                        <div>
                            <label
                                htmlFor="name"
                                className="text-sm font-medium text-slate-900"
                            >
                                Name
                            </label>

                            <input
                                id="name"
                                type="text"
                                value={name}
                                onChange={(event) =>
                                    setName(event.target.value)
                                }
                                placeholder="Your name"
                                required
                                className="mt-2 w-full rounded-lg border-2 border-black px-3 py-2.5 text-sm outline-none transition theme-accent-focus"
                            />
                        </div>

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
                                minLength={8}
                                className="mt-2 w-full rounded-lg border-2 border-black bg-white px-3 py-2.5 text-sm outline-none transition"
                            />

                            <p className="mt-1.5 text-xs text-slate-400">
                                Use at least 8 characters.
                            </p>
                        </div>

                        {error && (
                            <div className="rounded-lg border-2 border-black bg-red-50 p-3 text-sm text-red-700">
                                {error}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full rounded-lg border-2 border-black theme-accent-bg px-4 py-2.5 text-sm font-semibold text-black transition theme-accent-hover disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            {loading
                                ? 'Creating account...'
                                : 'Create account'}
                        </button>
                    </div>

                    <div className="mt-6 border-t border-slate-200 pt-5 text-center text-sm text-slate-500">
                        Already have an account?{' '}
                        <Link
                            to="/login"
                            className="font-medium text-black underline underline-offset-4"
                        >
                            Sign in
                        </Link>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default Register;