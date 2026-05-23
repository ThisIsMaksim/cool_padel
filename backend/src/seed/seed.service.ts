import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { User, UserDocument } from '../users/schemas/user.schema';
import {
  Tournament,
  TournamentDocument,
} from '../tournaments/schemas/tournament.schema';

@Injectable()
export class SeedService implements OnModuleInit {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(Tournament.name)
    private readonly tournamentModel: Model<TournamentDocument>,
  ) {}

  async onModuleInit() {
    await this.seedPlayers();
    await this.cleanupSeedTournaments();
    await this.seedDemoAccount();
  }

  private async seedPlayers() {
    const players = [
      {
        publicId: 'player_1',
        email: 'player1@coolpadel.app',
        name: 'Максим Федянин',
        rating: 1840,
        level: 'A',
        club: 'Padel Club Moscow',
        city: 'Москва',
        avatarColor: 0xff1565c0,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_2',
        email: 'player2@coolpadel.app',
        name: 'Алексей Смирнов',
        rating: 1720,
        level: 'B+',
        club: 'Padel Club Moscow',
        city: 'Москва',
        avatarColor: 0xff2e7d52,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_3',
        email: 'player3@coolpadel.app',
        name: 'Иван Петров',
        rating: 1650,
        level: 'B',
        club: 'Sky Padel',
        city: 'Москва',
        avatarColor: 0xffc62828,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_4',
        email: 'player4@coolpadel.app',
        name: 'Дмитрий Козлов',
        rating: 1580,
        level: 'B',
        club: 'Sky Padel',
        city: 'Москва',
        avatarColor: 0xff6a1b9a,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_5',
        email: 'player5@coolpadel.app',
        name: 'Сергей Волков',
        rating: 1490,
        level: 'C+',
        club: 'Luzhniki Padel',
        city: 'Москва',
        avatarColor: 0xffef6c00,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_6',
        email: 'player6@coolpadel.app',
        name: 'Анна Белова',
        rating: 1760,
        level: 'A',
        club: 'Padel Club Moscow',
        city: 'Москва',
        avatarColor: 0xff00838f,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_7',
        email: 'player7@coolpadel.app',
        name: 'Елена Соколова',
        rating: 1610,
        level: 'B',
        club: 'Luzhniki Padel',
        city: 'Москва',
        avatarColor: 0xffad1457,
        isSeedPlayer: true,
      },
      {
        publicId: 'player_8',
        email: 'player8@coolpadel.app',
        name: 'Олег Морозов',
        rating: 1420,
        level: 'C',
        club: 'Sky Padel',
        city: 'Москва',
        avatarColor: 0xff4527a0,
        isSeedPlayer: true,
      },
    ];

    for (const player of players) {
      await this.userModel.updateOne(
        { publicId: player.publicId },
        { $setOnInsert: player },
        { upsert: true },
      );
    }

    this.logger.log(`Seeded ${players.length} players`);
  }

  /** Удаляет демо-турниры из ранних версий (t1–t4). */
  private async cleanupSeedTournaments() {
    const result = await this.tournamentModel
      .deleteMany({ publicId: { $in: ['t1', 't2', 't3', 't4'] } })
      .exec();
    if (result.deletedCount > 0) {
      this.logger.log(`Removed ${result.deletedCount} seed tournaments`);
    }
  }

  private async seedDemoAccount() {
    const email = 'maksim@coolpadel.app';
    const passwordHash = await bcrypt.hash('123456', 10);
    await this.userModel.updateOne(
      { publicId: 'player_1' },
      {
        $set: {
          email,
          passwordHash,
          name: 'Максим Федянин',
          rating: 1840,
          level: 'A',
          club: 'Padel Club Moscow',
          city: 'Москва',
          avatarColor: 0xff1565c0,
          isSeedPlayer: false,
        },
      },
    );
    this.logger.log('Demo account ready: maksim@coolpadel.app / 123456');
  }
}
