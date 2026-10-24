import { betterAuth, type BetterAuthOptions } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';
import type { PrismaClient } from '../generated/prisma/client';
import { emailOTP } from 'better-auth/plugins';
import { EmailService } from '../email/email.service';

export function createAuth(prisma: PrismaClient, emailService: EmailService) {
  const options: BetterAuthOptions = {
    database: prismaAdapter(prisma, {
      provider: 'postgresql',
    }),

    emailAndPassword: {
      enabled: true,
    },

    plugins: [
      emailOTP({
        async sendVerificationOTP({ email, otp }) {
          await emailService.sendOtp(email, otp);
        },
      }),
    ],

    // The web app and this API run on different sites (e.g. Vercel + Render).
    // Browsers only attach cookies to cross-site fetch() calls when the cookie
    // is SameSite=None, and SameSite=None is only accepted with Secure. The
    // default (Lax) makes the session cookie disappear, so web login "fails".
    advanced: {
      defaultCookieAttributes: {
        sameSite: 'none',
        secure: true,
        httpOnly: true,
      },
    },
    trustedOrigins: [process.env.FRONTEND_URL!],
  };

  return betterAuth(options);
}

export type AppAuth = ReturnType<typeof createAuth>;
