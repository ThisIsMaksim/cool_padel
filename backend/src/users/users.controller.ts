import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AuthUser } from '../auth/auth.types';
import { UpdateProfileDto } from '../auth/dto/auth.dto';
import { UsersService } from './users.service';
import { TournamentsService } from '../tournaments/tournaments.service';

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly tournamentsService: TournamentsService,
  ) {}

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@CurrentUser() user: AuthUser) {
    const doc = await this.usersService.findById(user.userId);
    if (!doc) {
      return null;
    }
    const history = await this.tournamentsService.tournamentHistoryForPlayer(
      user.publicId,
    );
    return this.usersService.toProfileJson(doc, history);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('me')
  async updateMe(@CurrentUser() user: AuthUser, @Body() dto: UpdateProfileDto) {
    const doc = await this.usersService.updateProfile(user.userId, dto);
    const history = await this.tournamentsService.tournamentHistoryForPlayer(
      user.publicId,
    );
    return this.usersService.toProfileJson(doc, history);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/favorites')
  async favorites(@CurrentUser() user: AuthUser) {
    const ids = await this.usersService.getFavorites(user.userId);
    const players = await Promise.all(
      ids.map(async (id) => {
        try {
          const player = await this.usersService.getPlayerByPublicId(id);
          return this.usersService.toPlayerJson(player);
        } catch {
          return null;
        }
      }),
    );
    return players.filter(Boolean);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('me/favorites/:playerId/toggle')
  async toggleFavorite(
    @CurrentUser() user: AuthUser,
    @Param('playerId') playerId: string,
  ) {
    const favoriteIds = await this.usersService.toggleFavorite(
      user.userId,
      playerId,
    );
    return { favoriteIds };
  }
}
