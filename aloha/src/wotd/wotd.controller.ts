import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { AllowAnonymous } from "@thallesp/nestjs-better-auth";
import { WotdService } from "./wotd.service";

@AllowAnonymous()
@Controller("word-of-the-day")
export class WotdController {
    constructor(private readonly wordOfTheDayService: WotdService) { }

    @Get()
    findAll() {
        return this.wordOfTheDayService.findAll();
    }

    @Get(":id")
    findById(@Param("id", ParseIntPipe) id: number) {
        return this.wordOfTheDayService.findById(id);
    }
}