import { Module } from '@nestjs/common';
import { WotdService } from './wotd.service';
import { WotdController } from './wotd.controller';

@Module({
  providers: [WotdService],
  controllers: [WotdController]
})
export class WotdModule { }
