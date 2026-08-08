import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { UsersModule } from './users/users.module';
import { NotesModule } from './notes/notes.module';
import { PrismaModule } from './prisma/prisma.module';
import { ConfigModule } from "@nestjs/config";
import { WotdModule } from './wotd/wotd.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    UsersModule,
    NotesModule,
    WotdModule,
  ],
  controllers: [AppController],
})
export class AppModule { }
