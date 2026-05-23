import { Module, forwardRef } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { TournamentsModule } from '../tournaments/tournaments.module';
import { PlayersController } from './players.controller';

@Module({
  imports: [UsersModule, forwardRef(() => TournamentsModule)],
  controllers: [PlayersController],
})
export class PlayersModule {}
