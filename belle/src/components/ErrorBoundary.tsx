import type { ReactNode, ComponentType } from 'react';
import { ErrorBoundary, type FallbackProps } from 'react-error-boundary';

function DefaultErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
    const message = error instanceof Error ? error.message : 'An unexpected error occurred.';

    return (
        <div className="error-container">
            <h2>Something went wrong.</h2>
            <p>{message}</p>
            <button onClick={resetErrorBoundary}>Try Again</button>
        </div>
    );
}

type AppErrorBoundaryProps = {
    children: ReactNode;
    fallback?: ComponentType<FallbackProps>;
    onReset?: () => void;
};

export function AppErrorBoundary({
    children,
    fallback: Fallback = DefaultErrorFallback,
    onReset = () => window.location.reload(),
}: AppErrorBoundaryProps) {
    return (
        <ErrorBoundary FallbackComponent={Fallback} onReset={onReset}>
            {children}
        </ErrorBoundary>
    );
}