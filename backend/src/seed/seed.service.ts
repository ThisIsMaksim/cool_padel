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
    await this.seedTournaments();
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

  private async seedTournaments() {
    const count = await this.tournamentModel.countDocuments().exec();
    if (count > 0) {
      return;
    }

    const now = new Date();
    const tournaments = [
      {
        publicId: 't1',
        title: 'Weekend Open B+',
        description:
          'Открытый турнир для игроков уровня B+. Формат — олимпийская система, матчи до 2 сетов. Призы для финалистов.',
        club: 'Padel Club Moscow',
        address: 'ул. Ленинградская, 39',
        dateTime: new Date(now.getTime() + 2 * 86400000 + 10 * 3600000),
        level: 'B+',
        format: 'doubles' as const,
        maxParticipants: 16,
        organizerId: 'player_1',
        participantIds: ['player_1', 'player_2', 'player_3', 'player_6'],
        waitlistIds: [],
        status: 'open' as const,
      },
      {
        publicId: 't2',
        title: 'Sky Padel Singles Cup',
        description:
          'Одиночный турнир уровня B. Регистрация до начала первого матча.',
        club: 'Sky Padel',
        address: 'пр. Мира, 119',
        dateTime: new Date(now.getTime() + 5 * 86400000 + 18 * 3600000),
        level: 'B',
        format: 'singles' as const,
        maxParticipants: 12,
        organizerId: 'player_3',
        participantIds: ['player_3', 'player_4', 'player_5'],
        waitlistIds: [],
        status: 'open' as const,
      },
      {
        publicId: 't3',
        title: 'Luzhniki Night Padel',
        description: 'Вечерний парный турнир под открытым небом.',
        club: 'Luzhniki Padel',
        address: 'Лужники, 24',
        dateTime: new Date(now.getTime() + 86400000 + 20 * 3600000),
        level: 'A',
        format: 'doubles' as const,
        maxParticipants: 8,
        organizerId: 'player_6',
        participantIds: [
          'player_1',
          'player_2',
          'player_3',
          'player_4',
          'player_5',
          'player_6',
          'player_7',
          'player_8',
        ],
        waitlistIds: [],
        status: 'full' as const,
      },
      {
        publicId: 't4',
        title: 'Beginners Friendly',
        description: 'Турнир для новичков уровня C. Тренер на площадке.',
        club: 'Padel Club Moscow',
        address: 'ул. Ленинградская, 39',
        dateTime: new Date(now.getTime() + 7 * 86400000 + 11 * 3600000),
        level: 'C',
        format: 'doubles' as const,
        maxParticipants: 20,
        organizerId: 'player_1',
        participantIds: ['player_5', 'player_8'],
        waitlistIds: [],
        status: 'open' as const,
      },
    ];

    await this.tournamentModel.insertMany(tournaments);
    this.logger.log(`Seeded ${tournaments.length} tournaments`);
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
