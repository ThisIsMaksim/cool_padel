import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { NotificationsModule } from '../notifications/notifications.module';
import { OpenMatch, OpenMatchSchema } from './schemas/open-match.schema';
import { OpenMatchesService } from './open-matches.service';
import { OpenMatchesController } from './open-matches.controller';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: OpenMatch.name, schema: OpenMatchSchema },
    ]),
    NotificationsModule,
  ],
  providers: [OpenMatchesService],
  controllers: [OpenMatchesController],
})
export class OpenMatchesModule {}
