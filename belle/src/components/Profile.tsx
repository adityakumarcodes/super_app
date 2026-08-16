import { authClient } from '../utils/auth-client';
import Spinner from './Spinner';

const Profile = () => {
    const { data: session, isPending } = authClient.useSession();

    const handleLogout = async () => {
        await authClient.signOut();
        window.location.href = '/login';
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


            {/* Name */}
            <div className="flex items-center justify-between gap-6 border-b p-5">
                <div>
                    <p className="text-sm font-medium text-slate-900">
                        Name
                    </p>

                    <p className="mt-1 text-sm text-slate-500">
                        {user.name || 'No name set'}
                    </p>
                </div>
            </div>

            {/* Email */}
            <div className="flex items-center justify-between gap-6 border-b p-5">
                <div>
                    <p className="text-sm font-medium text-slate-900">
                        Email
                    </p>

                    <p className="mt-1 text-sm text-slate-500">
                        {user.email}
                    </p>
                </div>
            </div>

            {/* Logout */}
            <div className="flex items-center justify-between gap-6 p-5">
                <div>
                    <p className="text-sm font-medium text-slate-900">
                        Sign out
                    </p>

                    <p className="mt-1 text-sm text-slate-500">
                        Sign out of your Bellee account.
                    </p>
                </div>

                <button
                    type="button"
                    onClick={handleLogout}
                    className="rounded-lg border-2 border-black bg-white px-4 py-2 text-sm font-medium transition hover:bg-slate-100"
                >
                    Logout
                </button>
            </div>
        </div>
    );
};

export default Profile;