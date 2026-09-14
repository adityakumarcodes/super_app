import type { ReactNode } from 'react';
import { useNavigate } from '@tanstack/react-router';
import { authClient } from '../utils/auth-client';
import Spinner from './Spinner';

interface ProfileRowProps {
    label: string;
    value: ReactNode;
    children?: ReactNode;
    isLast?: boolean;
}

const ProfileRow = ({ label, value, children, isLast = false }: ProfileRowProps) => (
    <div className={`flex items-center justify-between gap-6 p-5 ${isLast ? '' : 'border-b'}`}>
        <div>
            <p className="text-sm font-medium text-slate-900">{label}</p>
            <p className="mt-1 text-sm text-slate-500">{value}</p>
        </div>
        {children}
    </div>
);

const Profile = () => {
    const { data: session, isPending } = authClient.useSession();
    const navigate = useNavigate();

    const handleLogout = async () => {
        await authClient.signOut();
        navigate({ to: '/login' });
    };

    if (isPending) {
        return <Spinner />
    }

    if (!session?.user) {
        return (
            <div className="m-6 rounded-2xl border-2 border-black bg-white p-5">
                <p className="text-sm text-slate-500">
                    You are not signed in.
                </p>
            </div>
        );
    }

    const { user } = session;

    return (
        <div className="m-6 rounded-2xl border-2 border-black bg-white">
            <ProfileRow label="Name" value={user.name || 'No name set'} />
            <ProfileRow label="Email" value={user.email} />
            <ProfileRow label="Sign out" value="Sign out of your account." isLast>
                <button
                    type="button"
                    onClick={handleLogout}
                    className="rounded-lg border-2 border-black bg-white px-4 py-2 text-sm font-medium transition hover:bg-slate-100"
                >
                    Logout
                </button>
            </ProfileRow>
        </div>
    );
};

export default Profile;