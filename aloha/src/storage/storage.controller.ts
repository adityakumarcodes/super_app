import {
  Controller,
  Post,
  Get,
  UploadedFile,
  UseInterceptors,
  Query,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { StorageService } from './storage.service';
import { Session, type UserSession } from '@thallesp/nestjs-better-auth';

@Controller('storage')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async upload(
    @UploadedFile() file: Express.Multer.File,
    @Session() session: UserSession,
  ) {
    const userId = session?.user?.id;
    if (!userId) {
      throw new UnauthorizedException();
    }
    return this.storageService.upload(file, userId);
  }

  @Get('url')
  async getSignedUrl(
    @Query('path') path: string,
    @Session() session: UserSession,
  ) {
    const userId = session?.user?.id;
    if (!userId) {
      throw new UnauthorizedException();
    }
    if (!path) {
      throw new BadRequestException('Storage path is required');
    }

    return this.storageService.getSignedUrl(path, userId);
  }
}
