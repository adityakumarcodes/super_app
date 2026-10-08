import { useState } from 'react';
import { Link, useNavigate } from '@tanstack/react-router';
import { authClient } from '../utils/auth-client';

const Login = () => {
    const [email, setEmail] = useState('');
    const [otp, setOtp] = useState('');
    const [step, setStep] = useState<'email' | 'otp'>('email');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const navigate = useNavigate();

    const handleSendOtp = async (event: React.FormEvent) => {
        event.preventDefault();

        setError('');
        setLoading(true);

        const { error } =
            await authClient.emailOtp.sendVerificationOtp({
                email,
                type: 'sign-in',
            });

        setLoading(false);

        if (error) {
            setError(error.message ?? 'Could not send OTP.');
            return;
        }

        setStep('otp');
    };

    const handleVerifyOtp = async (event: React.FormEvent) => {
        event.preventDefault();

        setError('');
        setLoading(true);

        const { error } = await authClient.signIn.emailOtp({
            email,
            otp,
        });

        setLoading(false);

        if (error) {
            setError(error.message ?? 'Invalid OTP.');
            return;
        }

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
                    onSubmit={
                        step === 'email'
                            ? handleSendOtp
                            : handleVerifyOtp
                    }
                    className="rounded-2xl border-2 border-black bg-white p-6"
                >
                    <div className="space-y-5">

                        {step === 'email' ? (
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
                        ) : (
                            <>
                                <div>
                                    <p className="text-sm text-slate-600">
                                        We sent a verification code to
                                    </p>

                                    <p className="mt-1 font-medium text-black">
                                        {email}
                                    </p>
                                </div>

                                <div>
                                    <label
                                        htmlFor="otp"
                                        className="text-sm font-medium text-slate-900"
                                    >
                                        Verification code
                                    </label>

                                    <input
                                        id="otp"
                                        type="text"
                                        inputMode="numeric"
                                        autoComplete="one-time-code"
                                        maxLength={6}
                                        value={otp}
                                        onChange={(event) =>
                                            setOtp(
                                                event.target.value.replace(
                                                    /\D/g,
                                                    '',
                                                ),
                                            )
                                        }
                                        placeholder="123456"
                                        required
                                        className="mt-2 w-full rounded-lg border-2 border-black bg-white px-3 py-2.5 text-center text-lg tracking-[0.3em] outline-none transition"
                                    />
                                </div>
                            </>
                        )}

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
                                ? step === 'email'
                                    ? 'Sending code...'
                                    : 'Verifying...'
                                : step === 'email'
                                  ? 'Send verification code'
                                  : 'Verify and sign in'}
                        </button>

                        {step === 'otp' && (
                            <button
                                type="button"
                                onClick={() => {
                                    setStep('email');
                                    setOtp('');
                                    setError('');
                                }}
                                className="w-full text-sm text-slate-500 underline underline-offset-4"
                            >
                                Use a different email
                            </button>
                        )}
                    </div>

                   
                </form>
            </div>
        </div>
    );
};

export default Login;