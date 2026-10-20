import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { PrismaModule } from './prisma/prisma.module';
import { ConfigModule } from "@nestjs/config";
import { WotdModule } from './wotd/wotd.module';
import { AuthModule } from './auth/auth.module';
import { NotesModule } from './notes/notes.module';
import { StorageModule } from './storage/storage.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    PrismaModule,
    WotdModule,
    NotesModule,
    StorageModule,
  ],
  controllers: [AppController],
})
export class AppModule { }
