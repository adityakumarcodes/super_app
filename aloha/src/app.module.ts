import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { PrismaModule } from './prisma/prisma.module';
import { ConfigModule } from "@nestjs/config";
import { WotdModule } from './wotd/wotd.module';
import { AuthModule } from './auth/auth.module';
import { NotesModule } from './notes/notes.module';
import { StorageModule } from './storage/storage.module';
import { EmailService } from './email/email.service';
import { EmailModule } from './email/email.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    PrismaModule,
    WotdModule,
    NotesModule,
    StorageModule,
    EmailModule,
  ],
  controllers: [AppController],
  providers: [EmailService],
})
export class AppModule { }
