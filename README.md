## Architecture

- **Aloha** (backend)
	- NestJS application with `Prisma` (Postgres)
	- Authentication via `better-auth` + `@thallesp/nestjs-better-auth`
	- `.env` loaded via `@nestjs/config`

- **Belle** (frontend)
	- Vite + React (TSX) app in `belle/`
	- `.env.local` uses `VITE_` prefixed variables


## Run the project

Start backend (from repo root):

```bash
cd aloha && npm run start:dev
```

Start frontend:

```bash
cd belle && npm run dev
```

After starting both, open the frontend (default): `http://localhost:5173`.
