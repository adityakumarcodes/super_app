import { CloudSun, Droplets, MapPin, Thermometer, Wind } from 'lucide-react';
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

const weatherApiKey = import.meta.env.VITE_WEATHER_API_KEY;

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
        enabled: Boolean(weatherQuery && weatherApiKey),
    });

    return (
        <section className="surface-card mx-auto max-w-5xl p-4 sm:p-6">
            {isLoading && <div className="flex min-h-52 items-center justify-center"><Spinner /></div>}
            {!weatherApiKey && <div className="theme-accent-soft rounded-2xl border border-strong p-5 text-center text-sm">Add <code>VITE_WEATHER_API_KEY</code> to show the local forecast.</div>}
            {isError && <p className="rounded-2xl border border-red-200 bg-red-50 p-4 text-center text-sm text-red-700">Weather is unavailable right now.</p>}
            {data && <div className="grid gap-3 md:grid-cols-3">
                {data.forecast.forecastday.slice(0, 3).map((day, index) => {
                    const isToday = index === 0;
                    const temperature = isToday ? data.current.temp_c : day.day.avgtemp_c;
                    const humidity = isToday ? data.current.humidity : day.day.avghumidity;
                    const wind = isToday ? data.current.wind_kph : day.day.maxwind_kph;
                    const condition = isToday ? data.current.condition : day.day.condition;

                    return (
                        <article className={`rounded-2xl border p-4 ${isToday ? 'theme-accent-soft border-strong' : 'surface-raised border-subtle'}`} key={day.date}>
                            <p className="text-sm font-medium text-secondary">{['Today', 'Tomorrow', 'Next day'][index]}</p>
                            <div className="my-4 flex items-center gap-3">
                                <img className="h-14 w-14" src={`https:${condition.icon}`} alt={condition.text} />
                                <div><p className="font-bodoni text-4xl leading-none">{Math.round(temperature)}°C</p><p className="mt-1 text-sm text-secondary">{condition.text}</p></div>
                            </div>
                            <div className="space-y-2 border-t border-subtle pt-3 text-xs text-secondary">
                                <p className="flex items-center justify-between gap-2"><span className="flex items-center gap-1.5"><Thermometer size={15} />High / Low</span><strong className="font-medium text-primary">{Math.round(day.day.maxtemp_c)}° / {Math.round(day.day.mintemp_c)}°</strong></p>
                                <p className="flex items-center justify-between gap-2"><span className="flex items-center gap-1.5"><Droplets size={15} />Humidity</span><strong className="font-medium text-primary">{Math.round(humidity)}%</strong></p>
                                <p className="flex items-center justify-between gap-2"><span className="flex items-center gap-1.5"><Wind size={15} />Wind</span><strong className="font-medium text-primary">{Math.round(wind)} km/h</strong></p>
                            </div>
                        </article>
                    );
                })}
            </div>}
        </section>
    );
}


