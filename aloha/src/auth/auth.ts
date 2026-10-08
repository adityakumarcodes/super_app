import { betterAuth, type BetterAuthOptions } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import type { PrismaClient } from "../generated/prisma/client";
import { emailOTP } from "better-auth/plugins";

export function createAuth(prisma: PrismaClient) {
    const options: BetterAuthOptions = {
        database: prismaAdapter(prisma, {
            provider: "postgresql",
        }),

        emailAndPassword: {
            enabled: true,
        },

        plugins: [
            emailOTP({
                async sendVerificationOTP({ email, otp, type }) {
                    console.log(`[OTP] ${type} → ${email}: ${otp}`);
                },
            }),
        ],

        trustedOrigins: [
            `http://localhost:${process.env.FRONTEND_PORT}`,
        ],
    };

    return betterAuth(options);
}

export type AppAuth = ReturnType<typeof createAuth>;