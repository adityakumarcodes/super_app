import { Droplets, Thermometer, Wind } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import Spinner from './Spinner';

type WeatherResponse = {
    location: {
        name: string;
        country: string;
    };
    current: {
        temp_c: number;
        feelslike_c: number;
        humidity: number;
        wind_kph: number;
        condition: {
            text: string;
            icon: string;
        };
    };
    forecast: {
        forecastday: Array<{
            date: string;
            day: {
                maxtemp_c: number;
                mintemp_c: number;
                avgtemp_c: number;
                avghumidity: number;
                maxwind_kph: number;
                condition: {
                    text: string;
                    icon: string;
                };
            };
        }>;
    };
};

const weatherApiKey = import.meta.env.VITE_WEATHER_API_KEY || 'db187b4e2bfe4d31a6c90817261909';

type WeatherWidgetProps = {
    place: string;
};

export default function WeatherWidget({ place }: WeatherWidgetProps) {
    const weatherQuery = place;
    const { data, isLoading, isError } = useQuery<WeatherResponse>({
        queryKey: ['weather', weatherQuery],
        queryFn: async ({ signal }) => {
            const response = await fetch(
                `https://api.weatherapi.com/v1/forecast.json?key=${weatherApiKey}&q=${encodeURIComponent(weatherQuery)}&days=3`,
                { signal },
            );

            if (!response.ok) throw new Error('Unable to load weather');
            return response.json() as Promise<WeatherResponse>;
        },
        staleTime: 10 * 60 * 1000,
        enabled: Boolean(weatherQuery),
    });

    return (
        <section className="mx-2 rounded-3xl border-2 border-black/10 bg-white p-5 font-poppins shadow-sm sm:p-6">
            {isLoading && <div className="flex min-h-40 items-center justify-center"><Spinner /></div>}
            {isError && <p className="rounded-2xl bg-red-50 p-4 text-center text-sm text-red-600">Weather is unavailable right now.</p>}
            {data && <div className="grid min-h-64 grid-cols-3">
                {data.forecast.forecastday.slice(0, 3).map((day, index) => {
                    const isToday = index === 0;
                    const temperature = isToday ? data.current.temp_c : day.day.avgtemp_c;
                    const humidity = isToday ? data.current.humidity : day.day.avghumidity;
                    const wind = isToday ? data.current.wind_kph : day.day.maxwind_kph;
                    const condition = isToday ? data.current.condition : day.day.condition;

                    return (
                        <div className={`flex min-w-0 self-stretch flex-col px-4 first:pl-0 last:pr-0 ${index > 0 ? 'border-l-2 border-black/10' : ''}`} key={day.date}>
                            <p className="text-center text-sm font-medium text-black sm:text-base">{['Today', 'Tomorrow', 'Next day'][index]}</p>
                            <div className="my-4 flex items-center justify-center gap-2">
                                <img className="h-14 w-14 sm:h-16 sm:w-16" src={`https:${condition.icon}`} alt={condition.text} />
                                <p className="font-bodoni text-3xl font-bold sm:text-4xl">{Math.round(temperature)}°C</p>
                            </div>
                            <p className="min-h-7 text-center text-xs text-gray-500 sm:text-sm">{condition.text}</p>
                            <div className="mt-auto space-y-3 border-t border-black/10 pt-4 text-xs text-gray-500 sm:text-sm">
                                <p className="flex items-center justify-between gap-2"><span className="flex items-center gap-1.5"><Thermometer size={15} />High / Low</span><strong className="font-medium text-black">{Math.round(day.day.maxtemp_c)}° / {Math.round(day.day.mintemp_c)}°</strong></p>
                                <p className="flex items-center justify-between gap-2"><span className="flex items-center gap-1.5"><Droplets size={15} />Humidity</span><strong className="font-medium text-black">{Math.round(humidity)}%</strong></p>
                                <p className="flex items-center justify-between gap-2"><span className="flex items-center gap-1.5"><Wind size={15} />Wind</span><strong className="font-medium text-black">{Math.round(wind)} km/h</strong></p>
                            </div>
                        </div>
                    );
                })}
            </div>}
        </section>
    );
}
