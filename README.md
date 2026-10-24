## Architecture

- **Aloha** (NestJS backend)
  - NestJS with Prisma ORM.
  - Better Auth for authentication, integrated with NestJS using `@thallesp/nestjs-better-auth`.
  - Supabase PostgreSQL for database storage.
  - Supabase Storage for file and image storage.
  - Environment variables managed through `@nestjs/config`.
    - DATABASE_URL=?
    - DIRECT_URL=?
    - SUPABASE_URL=?
    - SUPABASE_SECRET_KEY=?
    - BETTER_AUTH_SECRET=?
    - BETTER_AUTH_URL=frontend_url
    - BACKEND_PORT=3000
    - FRONTEND_PORT=5173
    - RESEND_API_KEY=?

- **Belle** (Web frontend)
  - Vite + React (TSX) app in `belle/`
  - Communicates with Aloha through its API.
  - Uses `VITE_`-prefixed environment variables.
    - VITE_FRONTEND_PORT=5173
    - VITE_BACKEND_PORT=3000

- **Milo** (Mobile application)
  - Built with Flutter.
  - Communicates with Aloha through its API.

## TODO

- ✅Darkmode
- ✅Why authenticated user can see the login register routes
- ✅Integrate milo
- ✅Email OTP login.
- ✅Migrate to Bloc state management
- ✅delete image should delete from storage also
- ✅Build apk automatically on any changes in the milo
- ✅Notes CRUD
- Update backend dependency
- Prisma upgrade
- Admin can control the user visible mini-apps.
- Replace screenshot with figma url
- Explore single env use

https://medium.com/@balajibal/super-apps-the-operating-system-of-everyday-life-38706471a94b
https://github.com/itsmbaqer/mini-programs-guidelines

## Run the project

Start frontend & backend (from repo root):

```bash
pnpm web
```

Start mobile:

```bash
adb connect <ip> && dart format lib && flutter run --dart-define=API_BASE_URL=http://192.168.1.11:3000/api
```

Optional: Build a production APK and install it with one command

```bash
flutter build apk --release &&
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Screenshots

Below are a few UI screenshots from the Belle frontend.

### Home

![Home screenshot](screenshots/home.png)

### Notes

![Notes screenshot](screenshots/notes.png)

### Chat

![Chat screenshot](screenshots/chat.png)

### Calendar

![Chat screenshot](screenshots/calendar.png)

### Shop

![Shop screenshot](screenshots/shop.png)

![Shop screenshot](screenshots/details.png)

![Shop screenshot](screenshots/cart.png)

### Social

![Chat screenshot](screenshots/social.png)
