import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Tournament, TournamentDocument } from './schemas/tournament.schema';
import {
  CreateTournamentDto,
  ListTournamentsQueryDto,
  RegisterTournamentDto,
} from '../common/dto/api.dto';

@Injectable()
export class TournamentsService {
  constructor(
    @InjectModel(Tournament.name)
    private readonly tournamentModel: Model<TournamentDocument>,
  ) {}

  async list(query: ListTournamentsQueryDto) {
    const tournaments = await this.tournamentModel.find().sort({ dateTime: 1 }).exec();
    return tournaments
      .filter((t) => this.matchesFilters(t, query))
      .map((t) => this.toClientJson(t));
  }

  async active() {
    const tournaments = await this.tournamentModel
      .find({ status: { $ne: 'finished' } })
      .sort({ dateTime: 1 })
      .exec();
    return tournaments.map((t) => this.toClientJson(t));
  }

  async byId(id: string) {
    const tournament = await this.tournamentModel.findOne({ publicId: id }).exec();
    if (!tournament) {
      throw new NotFoundException('Tournament not found');
    }
    return this.toClientJson(tournament);
  }

  async create(organizerId: string, dto: CreateTournamentDto) {
    const dateTime = new Date(dto.dateTime);
    if (Number.isNaN(dateTime.getTime())) {
      throw new BadRequestException('Некорректная дата турнира');
    }
    if (dateTime.getTime() <= Date.now()) {
      throw new BadRequestException('Дата турнира должна быть в будущем');
    }
    if (dto.format === 'doubles' && dto.maxParticipants % 2 !== 0) {
      throw new BadRequestException(
        'Для парного турнира число участников должно быть чётным',
      );
    }

    const publicId = `t_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
    const tournament = await this.tournamentModel.create({
      publicId,
      title: dto.title.trim(),
      description: dto.description.trim(),
      club: dto.club.trim(),
      address: dto.address.trim(),
      dateTime,
      level: dto.level,
      format: dto.format,
      maxParticipants: dto.maxParticipants,
      organizerId,
      participantIds: [organizerId],
      waitlistIds: [],
      status: 'open',
    });

    return this.toClientJson(tournament);
  }

  async tournamentHistoryForPlayer(playerId: string) {
    const tournaments = await this.tournamentModel
      .find({ participantIds: playerId })
      .select('publicId')
      .exec();
    return tournaments.map((t) => t.publicId);
  }

  async register(id: string, userId: string, dto: RegisterTournamentDto) {
    const tournament = await this.tournamentModel.findOne({ publicId: id }).exec();
    if (!tournament) {
      throw new NotFoundException('Tournament not found');
    }

    if (tournament.participantIds.includes(userId)) {
      throw new BadRequestException('Вы уже записаны');
    }

    const slotsNeeded = tournament.format === 'doubles' ? 2 : 1;
    const idsToAdd = [userId];
    if (dto.partnerId) {
      idsToAdd.push(dto.partnerId);
    }

    if (idsToAdd.length < slotsNeeded) {
      throw new BadRequestException('Выберите партнёра для парного турнира');
    }

    const freeSlots = Math.max(
      0,
      tournament.maxParticipants - tournament.participantIds.length,
    );

    if (freeSlots < slotsNeeded) {
      if (!tournament.waitlistIds.includes(userId)) {
        tournament.waitlistIds.push(userId);
        await tournament.save();
      }
      return this.toClientJson(tournament);
    }

    tournament.participantIds.push(...idsToAdd);
    if (tournament.participantIds.length >= tournament.maxParticipants) {
      tournament.status = 'full';
    }
    await tournament.save();
    return this.toClientJson(tournament);
  }

  private matchesFilters(
    tournament: TournamentDocument,
    query: ListTournamentsQueryDto,
  ) {
    if (query.status && tournament.status !== query.status) {
      return false;
    }
    if (query.level && query.level !== 'Все' && tournament.level !== query.level) {
      return false;
    }
    if (query.format && tournament.format !== query.format) {
      return false;
    }
    if (query.club && query.club !== 'Все' && tournament.club !== query.club) {
      return false;
    }
    if (query.day && query.day !== 'Все') {
      const weekday = this.weekdayLabel(tournament.dateTime);
      if (weekday !== query.day) {
        return false;
      }
    }
    return true;
  }

  private weekdayLabel(date: Date) {
    const labels = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    return labels[date.getDay()] ?? '';
  }

  private toClientJson(tournament: TournamentDocument) {
    return {
      id: tournament.publicId,
      title: tournament.title,
      description: tournament.description,
      club: tournament.club,
      address: tournament.address,
      dateTime: tournament.dateTime.toISOString(),
      level: tournament.level,
      format: tournament.format,
      maxParticipants: tournament.maxParticipants,
      organizerId: tournament.organizerId,
      participantIds: tournament.participantIds,
      waitlistIds: tournament.waitlistIds,
      status: tournament.status,
    };
  }
}
