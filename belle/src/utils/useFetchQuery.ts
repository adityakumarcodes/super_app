import { useQuery, type QueryKey, type UseQueryOptions } from '@tanstack/react-query'
import axios from 'axios'

type Params<TData> = {
    queryKey: QueryKey
    queryLink: string
    queryOptions?: Omit<UseQueryOptions<TData>, 'queryKey' | 'queryFn'>
}

export default function useFetchQuery<TData = unknown>({ queryKey, queryLink, queryOptions }: Params<TData>) {
    return useQuery<TData>({
        queryKey,
        queryFn: async ({ signal }) => {
            const res = await axios.get<TData>(queryLink, { signal })
            return res.data
        },
        ...queryOptions,
    })
}
