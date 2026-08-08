import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class WotdService {
    constructor(private readonly prisma: PrismaService) { }

    async findAll() {
        return this.prisma.wordOfTheDay.findMany({
            orderBy: {
                id: "asc",
            },
        });
    }

    async findById(id: number) {
        return this.prisma.wordOfTheDay.findUnique({
            where: {
                id,
            },
        });
    }
}