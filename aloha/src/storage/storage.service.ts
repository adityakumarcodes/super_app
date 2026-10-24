import {
  Injectable,
  InternalServerErrorException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { randomUUID } from 'node:crypto';
import { extname } from 'node:path';

interface CachedSignedUrl {
  url: string;
  expiresAt: number;
}

@Injectable()
export class StorageService {
  private readonly supabase: SupabaseClient;
  private readonly bucket = 'superapp';
  private readonly signedUrlTtl = 3600;
  private readonly urlCache = new Map<string, CachedSignedUrl>();

  constructor(private readonly config: ConfigService) {
    this.supabase = createClient(
      this.config.getOrThrow<string>('SUPABASE_URL'),
      this.config.getOrThrow<string>('SUPABASE_SECRET_KEY'),
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
          detectSessionInUrl: false,
        },
      },
    );
  }

  async upload(file: Express.Multer.File, userId: string) {
    if (!userId) {
      throw new BadRequestException('Authenticated user is required');
    }

    if (!file?.buffer || !file.mimetype.startsWith('image/')) {
      throw new BadRequestException('A valid image file is required');
    }

    const extension = extname(file.originalname).toLowerCase();
    const filename = `${randomUUID()}${extension}`;
    const path = `notes/${userId}/${filename}`;

    const { data, error } = await this.supabase.storage
      .from(this.bucket)
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (error) {
      throw new InternalServerErrorException(
        `Image upload failed: ${error.message}`,
      );
    }

    return {
      path: data.path,
      ...(await this.getSignedUrl(data.path, userId)),
    };
  }

  private assertOwnedPath(path: string, userId: string) {
    if (
      !path ||
      path.startsWith('/') ||
      path.includes('..') ||
      path.includes('\\')
    ) {
      throw new ForbiddenException('Access to this fiel is not allowed');
    }
  }
  async getSignedUrl(path: string, userId: string) {
    this.assertOwnedPath(path, userId);
    const cached = this.urlCache.get(path);

    // Refresh one minute before expiration.
    if (cached && cached.expiresAt > Date.now() + 60_000) {
      return {
        url: cached.url,
        expiresIn: Math.floor((cached.expiresAt - Date.now()) / 1000),
      };
    }

    const { data, error } = await this.supabase.storage
      .from(this.bucket)
      .createSignedUrl(path, this.signedUrlTtl);

    if (error) {
      throw new InternalServerErrorException(
        `Failed to generate signed URL: ${error.message}`,
      );
    }

    const expiresAt = Date.now() + this.signedUrlTtl * 1000;

    this.urlCache.set(path, {
      url: data.signedUrl,
      expiresAt,
    });

    return {
      url: data.signedUrl,
      expiresIn: this.signedUrlTtl,
    };
  }

  async delete(path: string, userId: string) {
    this.assertOwnedPath(path, userId);
    if (!path || path.startsWith('/') || path.includes('..')) {
      throw new BadRequestException('Invalid storage path');
    }

    const { error } = await this.supabase.storage
      .from(this.bucket)
      .remove([path]);

    if (error) {
      throw new InternalServerErrorException(
        `Image delete failed: ${error.message}`,
      );
    }

    this.urlCache.delete(path);
  }
}
