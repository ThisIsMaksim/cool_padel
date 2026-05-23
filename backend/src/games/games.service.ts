import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Game, GameDocument } from './schemas/game.schema';
import {
  CreateGameDto,
  UpdateDeuceRuleDto,
  UpdateStandardStateDto,
  UpdateTournamentStateDto,
} from '../common/dto/api.dto';

@Injectable()
export class GamesService {
  constructor(@InjectModel(Game.name) private readonly gameModel: Model<GameDocument>) {}

  async list(ownerId: string, status?: 'inProgress' | 'finished') {
    const filter: Record<string, unknown> = { ownerId };
    if (status) {
      filter.status = status;
    }
    const games = await this.gameModel
      .find(filter)
      .sort({ createdAt: -1 })
      .exec();
    return games.map((g) => this.toClientJson(g));
  }

  async getById(ownerId: string, id: string) {
    const game = await this.gameModel.findById(id).exec();
    if (!game) {
      throw new NotFoundException('Game not found');
    }
    if (game.ownerId !== ownerId) {
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
    const state = dto.standardState;
    const isFinished = Boolean(state.isFinished ?? state.winnerIndex != null);

    game.standardState = state;
    game.status = isFinished ? 'finished' : 'inProgress';
    await game.save();
    return this.toClientJson(game);
  }

  async updateTournamentState(
    ownerId: string,
    id: string,
    dto: UpdateTournamentStateDto,
  ) {
    const game = await this.requireOwnedGame(ownerId, id);
    const state = dto.tournamentState;
    const isFinished = Boolean(state.isFinished ?? state.winnerIndex != null);

    game.tournamentState = state;
    game.status = isFinished ? 'finished' : 'inProgress';
    await game.save();
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
