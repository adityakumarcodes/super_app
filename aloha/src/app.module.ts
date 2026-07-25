import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { UsersController } from "./users/users.controller";
import { UsersService } from "./users/users.service";
import { PrismaService } from './prisma/prisma.service';
import { UsersModule } from './users/users.module';

@Module({
  imports: [UsersModule],
  controllers: [
    AppController,
    UsersController
  ],
  providers: [
    PrismaService,
    UsersService
  ],
})
export class AppModule { }
