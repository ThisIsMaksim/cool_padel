import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Tournament, TournamentSchema } from './schemas/tournament.schema';
import { TournamentsService } from './tournaments.service';
import { TournamentsController } from './tournaments.controller';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Tournament.name, schema: TournamentSchema },
    ]),
  ],
  providers: [TournamentsService],
  controllers: [TournamentsController],
  exports: [TournamentsService, MongooseModule],
})
export class TournamentsModule {}
