import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { UsersController } from "./users/users.controller";
import { UsersService } from "./users/users.service";
import { PrismaService } from './utils/prisma.service';
import { UsersModule } from './users/users.module';
import { NotesModule } from './notes/notes.module';


@Module({
  imports: [UsersModule, NotesModule],
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
