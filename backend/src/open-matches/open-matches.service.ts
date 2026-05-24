import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateOpenMatchDto } from '../common/dto/api.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { OpenMatch, OpenMatchDocument } from './schemas/open-match.schema';

@Injectable()
export class OpenMatchesService {
  constructor(
    @InjectModel(OpenMatch.name)
    private readonly openMatchModel: Model<OpenMatchDocument>,
    private readonly notificationsService: NotificationsService,
  ) {}

  list() {
    return this.openMatchModel
      .find({ status: 'open', dateTime: { $gte: new Date() } })
      .sort({ dateTime: 1 })
      .exec()
      .then((items) => items.map((item) => this.toClientJson(item)));
  }

  mine(creatorId: string) {
    return this.openMatchModel
      .find({ creatorId })
      .sort({ dateTime: -1 })
      .exec()
      .then((items) => items.map((item) => this.toClientJson(item)));
  }

  async create(creatorId: string, dto: CreateOpenMatchDto) {
    const dateTime = new Date(dto.dateTime);
    if (Number.isNaN(dateTime.getTime()) || dateTime.getTime() <= Date.now()) {
      throw new BadRequestException('Дата должна быть в будущем');
    }

    const maxPlayers = dto.format === 'doubles' ? 4 : 2;
    const publicId = `om_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;

    const openMatch = await this.openMatchModel.create({
      publicId,
      creatorId,
      club: dto.club.trim(),
      address: dto.address?.trim() ?? '',
      dateTime,
      level: dto.level,
      format: dto.format,
      maxPlayers,
      note: dto.note?.trim(),
      participantIds: [creatorId],
      status: 'open',
    });

    return this.toClientJson(openMatch);
  }

  async join(id: string, userId: string) {
    const openMatch = await this.openMatchModel.findOne({ publicId: id }).exec();
    if (!openMatch) {
      throw new NotFoundException('Open match not found');
    }
    if (openMatch.status !== 'open') {
      throw new BadRequestException('Набор закрыт');
    }
    if (openMatch.participantIds.includes(userId)) {
      throw new BadRequestException('Вы уже в списке');
    }
    if (openMatch.participantIds.length >= openMatch.maxPlayers) {
      throw new BadRequestException('Мест нет');
    }

    openMatch.participantIds.push(userId);
    if (openMatch.participantIds.length >= openMatch.maxPlayers) {
      openMatch.status = 'full';
    }
    await openMatch.save();

    if (userId !== openMatch.creatorId) {
      await this.notificationsService.create({
        userPublicId: openMatch.creatorId,
        type: 'open_match_join',
        title: 'Новый игрок в open match',
        body: `К вашей игре в ${openMatch.club} присоединился игрок`,
        linkPath: `/open-match/${openMatch.publicId}`,
      });
    }

    await this.notificationsService.createMany(openMatch.participantIds, {
      type: 'open_match_update',
      title: openMatch.status === 'full' ? 'Состав набран' : 'Open match обновлён',
      body:
        openMatch.status === 'full'
          ? `Игра в ${openMatch.club} — все места заняты`
          : `К игре в ${openMatch.club} присоединился новый игрок`,
      linkPath: `/open-match/${openMatch.publicId}`,
    });

    return this.toClientJson(openMatch);
  }

  async cancel(id: string, userId: string) {
    const openMatch = await this.openMatchModel.findOne({ publicId: id }).exec();
    if (!openMatch) {
      throw new NotFoundException('Open match not found');
    }
    if (openMatch.creatorId !== userId) {
      throw new BadRequestException('Только создатель может отменить');
    }
    openMatch.status = 'cancelled';
    await openMatch.save();
    return this.toClientJson(openMatch);
  }

  private toClientJson(openMatch: OpenMatchDocument) {
    return {
      id: openMatch.publicId,
      creatorId: openMatch.creatorId,
      club: openMatch.club,
      address: openMatch.address,
      dateTime: openMatch.dateTime.toISOString(),
      level: openMatch.level,
      format: openMatch.format,
      maxPlayers: openMatch.maxPlayers,
      note: openMatch.note ?? '',
      participantIds: openMatch.participantIds,
      status: openMatch.status,
      freeSlots: Math.max(
        0,
        openMatch.maxPlayers - openMatch.participantIds.length,
      ),
    };
  }
}
