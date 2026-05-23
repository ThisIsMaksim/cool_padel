import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../users/schemas/user.schema';
import { Tournament, TournamentSchema } from '../tournaments/schemas/tournament.schema';
import { SeedService } from './seed.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Tournament.name, schema: TournamentSchema },
    ]),
  ],
  providers: [SeedService],
})
export class SeedModule {}
