import { Module, forwardRef } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PlayersModule } from './players/players.module';
import { GamesModule } from './games/games.module';
import { TournamentsModule } from './tournaments/tournaments.module';
import { SeedModule } from './seed/seed.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get<string>(
          'MONGODB_URI',
          'mongodb://127.0.0.1:27017/cool_padel',
        ),
      }),
    }),
    AuthModule,
    UsersModule,
    PlayersModule,
    GamesModule,
    TournamentsModule,
    SeedModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
