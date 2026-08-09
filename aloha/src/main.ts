import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.enableCors({
    origin: `http://localhost:${process.env.FRONTEND_PORT!}`,
    credentials: true,
  });
  app.setGlobalPrefix('api');
  await app.listen(process.env.BACKEND_PORT!);
}

bootstrap();
