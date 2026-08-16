import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import type { PrismaClient } from "../generated/prisma/client";

export function createAuth(prisma: PrismaClient) {
    return betterAuth({
        database: prismaAdapter(prisma, {
            provider: "postgresql",
        }),
        emailAndPassword: {
            enabled: true,
        },
        trustedOrigins: ['http://localhost:' + process.env.FRONTEND_PORT!],
    });
}

export type AppAuth = ReturnType<typeof createAuth>;
