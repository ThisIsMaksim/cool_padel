import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { NotificationsService } from '../notifications/notifications.service';
import { RatingService } from '../rating/rating.service';
import { Game, GameDocument } from './schemas/game.schema';
import {
  CreateGameDto,
  UpdateDeuceRuleDto,
  UpdateStandardStateDto,
  UpdateTournamentStateDto,
} from '../common/dto/api.dto';

@Injectable()
export class GamesService {
  constructor(
    @InjectModel(Game.name) private readonly gameModel: Model<GameDocument>,
    private readonly ratingService: RatingService,
    private readonly notificationsService: NotificationsService,
  ) {}

  listForUser(
    ownerId: string,
    publicId: string,
    status?: 'inProgress' | 'finished',
  ) {
    const filter: Record<string, unknown> = {
      $or: [{ ownerId }, { 'config.participantIds': publicId }],
    };
    if (status) {
      filter.status = status;
    }
    return this.gameModel
      .find(filter)
      .sort({ createdAtIso: -1 })
      .exec()
      .then((games) => games.map((g) => this.toClientJson(g)));
  }

  async statsForUser(publicId: string) {
    const games = await this.gameModel
      .find({
        status: 'finished',
        'config.participantIds': publicId,
      })
      .sort({ createdAtIso: -1 })
      .exec();

    let wins = 0;
    let losses = 0;
    let draws = 0;
    let currentStreak = 0;
    let bestStreak = 0;
    let streakType: 'win' | 'loss' | null = null;

    for (const game of games) {
      const outcome = this.outcomeForPlayer(game, publicId);
      if (outcome === 'win') {
        wins++;
        if (streakType === 'win') {
          currentStreak++;
        } else {
          streakType = 'win';
          currentStreak = 1;
        }
      } else if (outcome === 'loss') {
        losses++;
        if (streakType === 'loss') {
          currentStreak++;
        } else {
          streakType = 'loss';
          currentStreak = 1;
        }
      } else {
        draws++;
        streakType = null;
        currentStreak = 0;
      }
      if (streakType === 'win') {
        bestStreak = Math.max(bestStreak, currentStreak);
      }
    }

    const winStreak =
      streakType === 'win' ? currentStreak : streakType === 'loss' ? -currentStreak : 0;

    return {
      totalGames: games.length,
      wins,
      losses,
      draws,
      winRate: games.length === 0 ? 0 : Math.round((wins / games.length) * 100),
      currentStreak: winStreak,
      bestWinStreak: bestStreak,
    };
  }

  async getById(ownerId: string, publicId: string, id: string) {
    const game = await this.gameModel.findById(id).exec();
    if (!game) {
      throw new NotFoundException('Game not found');
    }
    const participants =
      ((game.config as Record<string, unknown>).participantIds as string[]) ??
      [];
    if (game.ownerId !== ownerId && !participants.includes(publicId)) {
      throw new ForbiddenException();
    }
    return this.toClientJson(game);
  }

  async create(ownerId: string, dto: CreateGameDto) {
    const config = dto.config as Record<string, unknown>;
    const mode = config.mode as string;
    const now = new Date();

    const standardState =
      mode === 'standard'
        ? {
            setsToWin: config.setsToWin ?? 2,
            deuceRule: config.deuceRule ?? 'advantage',
            servingTeamIndex: dto.servingTeamIndex,
            servingPlayerIndex: dto.servingPlayerIndex,
            completedSets: [],
            currentSet: { team1Games: 0, team2Games: 0 },
            team1Points: 0,
            team2Points: 0,
            pointPhase: 'normal',
            goldenPointNext: false,
            isTiebreak: false,
            winnerIndex: null,
            history: [],
          }
        : undefined;

    const tournamentState =
      mode === 'tournament'
        ? {
            totalPoints: config.totalPoints ?? 50,
            minPointLead: config.minPointLead ?? 2,
            servingTeamIndex: dto.servingTeamIndex,
            servingPlayerIndex: dto.servingPlayerIndex,
            firstServingTeamIndex: dto.servingTeamIndex,
            team1Points: 0,
            team2Points: 0,
            winnerIndex: null,
            history: [],
          }
        : undefined;

    const game = await this.gameModel.create({
      ownerId,
      createdAtIso: now.toISOString(),
      status: 'inProgress',
      config,
      standardState,
      tournamentState,
    });

    return this.toClientJson(game);
  }

  async updateStandardState(
    ownerId: string,
    id: string,
    dto: UpdateStandardStateDto,
  ) {
    const game = await this.requireOwnedGame(ownerId, id);
    const wasFinished = game.status === 'finished';
    const state = dto.standardState;
    const isFinished = Boolean(state.isFinished ?? state.winnerIndex != null);

    game.standardState = state;
    game.status = isFinished ? 'finished' : 'inProgress';
    await game.save();

    if (isFinished && !wasFinished) {
      await this.onGameFinished(game);
    }

    return this.toClientJson(game);
  }

  async updateTournamentState(
    ownerId: string,
    id: string,
    dto: UpdateTournamentStateDto,
  ) {
    const game = await this.requireOwnedGame(ownerId, id);
    const wasFinished = game.status === 'finished';
    const state = dto.tournamentState;
    const isFinished = Boolean(state.isFinished ?? state.winnerIndex != null);

    game.tournamentState = state;
    game.status = isFinished ? 'finished' : 'inProgress';
    await game.save();

    if (isFinished && !wasFinished) {
      await this.onGameFinished(game);
    }

    return this.toClientJson(game);
  }

  async updateDeuceRule(ownerId: string, id: string, dto: UpdateDeuceRuleDto) {
    const game = await this.requireOwnedGame(ownerId, id);
    if (!game.standardState) {
      throw new NotFoundException('Standard state not found');
    }

    game.config = {
      ...(game.config as Record<string, unknown>),
      deuceRule: dto.deuceRule,
    };
    game.standardState = {
      ...(game.standardState as Record<string, unknown>),
      deuceRule: dto.deuceRule,
    };
    await game.save();
    return this.toClientJson(game);
  }

  async remove(ownerId: string, id: string) {
    const game = await this.requireOwnedGame(ownerId, id);
    await game.deleteOne();
    return { ok: true };
  }

  private async onGameFinished(game: GameDocument) {
    const config = game.config as Record<string, unknown>;
    const team1Ids = this.memberIds(config, 'team1Members');
    const team2Ids = this.memberIds(config, 'team2Members');
    const winnerIndex = this.winnerIndex(game);

    await this.ratingService.applyMatchResult({
      team1Ids,
      team2Ids,
      winnerIndex,
    });

    const participantIds =
      (config.participantIds as string[] | undefined) ??
      [...team1Ids, ...team2Ids];
    const team1Name = config.team1Name as string;
    const team2Name = config.team2Name as string;
    const score = this.scoreLabel(game);

    await this.notificationsService.createMany(participantIds, {
      type: 'game_finished',
      title: 'Матч завершён',
      body: `${team1Name} vs ${team2Name} · ${score}`,
      linkPath: `/game/${game._id.toString()}`,
    });
  }

  private winnerIndex(game: GameDocument): number | null {
    const standard = game.standardState as Record<string, unknown> | undefined;
    if (standard?.winnerIndex != null) {
      return standard.winnerIndex as number;
    }
    const tournament = game.tournamentState as Record<string, unknown> | undefined;
    if (tournament?.winnerIndex != null) {
      return tournament.winnerIndex as number;
    }
    return null;
  }

  private scoreLabel(game: GameDocument) {
    const config = game.config as Record<string, unknown>;
    const standard = game.standardState as Record<string, unknown> | undefined;
    if (standard) {
      const sets1 = (standard.completedSets as Array<Record<string, number>>)?.filter(
        (s) => (s.team1Games ?? 0) > (s.team2Games ?? 0),
      ).length ?? 0;
      const sets2 = (standard.completedSets as Array<Record<string, number>>)?.filter(
        (s) => (s.team2Games ?? 0) > (s.team1Games ?? 0),
      ).length ?? 0;
      return `Сеты ${sets1}:${sets2}`;
    }
    const tournament = game.tournamentState as Record<string, unknown> | undefined;
    if (tournament) {
      return `${tournament.team1Points}:${tournament.team2Points}`;
    }
    return 'Завершена';
  }

  private memberIds(config: Record<string, unknown>, key: string) {
    const members = config[key] as Array<{ playerId?: string }> | undefined;
    return members?.map((m) => m.playerId).filter(Boolean) as string[] ?? [];
  }

  private outcomeForPlayer(game: GameDocument, publicId: string) {
    const config = game.config as Record<string, unknown>;
    const team1Ids = this.memberIds(config, 'team1Members');
    const onTeam1 = team1Ids.includes(publicId);
    const winnerIndex = this.winnerIndex(game);
    if (winnerIndex == null) {
      return 'draw' as const;
    }
    if (onTeam1) {
      return winnerIndex === 0 ? ('win' as const) : ('loss' as const);
    }
    return winnerIndex === 1 ? ('win' as const) : ('loss' as const);
  }

  private async requireOwnedGame(ownerId: string, id: string) {
    const game = await this.gameModel.findById(id).exec();
    if (!game) {
      throw new NotFoundException('Game not found');
    }
    if (game.ownerId !== ownerId) {
      throw new ForbiddenException();
    }
    return game;
  }

  private toClientJson(game: GameDocument) {
    return {
      id: game._id.toString(),
      createdAt: game.createdAtIso,
      status: game.status,
      config: game.config,
      ...(game.standardState ? { standardState: game.standardState } : {}),
      ...(game.tournamentState ? { tournamentState: game.tournamentState } : {}),
    };
  }
}
