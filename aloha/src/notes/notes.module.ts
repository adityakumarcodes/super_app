import { Module } from '@nestjs/common';
import { NotesService } from './notes.service';
import { NotesController } from './notes.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { StorageService } from '../storage/storage.service';

@Module({
  imports: [PrismaModule],
  providers: [NotesService, StorageService],
  controllers: [NotesController],
})
export class NotesModule {}
