const stackItems = [
    { label: 'Frontend', value: 'Vite + TanStack Router' },
    { label: 'Backend', value: 'NestJS + PrismaORM(https://www.youtube.com/watch?v=skQXoZ8chxk)' },
    { label: 'Database', value: 'Prisma Postgres' },
    { label: 'Authentication', value: 'BetterAuth(https://github.com/thallesp/nestjs-better-auth)' },
];

const About = () => {
    return (
        <div className="rounded-2xl border-2 p-6 m-6">
            <ul className="space-y-3 list-disc pl-5">
                {stackItems.map((item) => (
                    <li key={item.label} className="p-2">
                        <span className="text-slate-900 font-medium">{item.label}:</span>{' '}
                        <span className="text-slate-700">{item.value}</span>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default About;
