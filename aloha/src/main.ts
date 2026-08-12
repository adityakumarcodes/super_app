import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.enableCors({
    origin: `http://localhost:${process.env.FRONTEND_PORT!}`,
    credentials: true,
  });
  app.setGlobalPrefix('api');
  const port = Number(process.env.BACKEND_PORT!);
  console.log(`Starting backend on http://localhost:${port}...`);

  await app.listen(port);

  console.log(`Backend running on http://localhost:${port}`);
}

bootstrap();
