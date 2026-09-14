import { useQuery, type QueryKey, type UseQueryOptions } from '@tanstack/react-query'

type Params<TData> = {
    queryKey: QueryKey
    queryLink: string
    queryOptions?: Omit<UseQueryOptions<TData>, 'queryKey' | 'queryFn'>
}

export default function useFetchQuery<TData = unknown>({
    queryKey,
    queryLink,
    queryOptions,
}: Params<TData>) {
    return useQuery<TData>({
        queryKey,
        queryFn: async ({ signal }) => {
            const res = await fetch(queryLink, {
                signal,
                credentials: 'include', // This is equivalent to axios' withCredentials: true
            });

            if (!res.ok) {
                // fetch() does not throw on HTTP errors, so we need to check for them manually.
                throw new Error(`Network response was not ok: ${res.statusText}`);
            }

            return res.json();
        },
        ...queryOptions,
    });
}