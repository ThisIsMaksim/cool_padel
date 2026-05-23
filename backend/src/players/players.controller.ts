import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { TournamentsService } from '../tournaments/tournaments.service';

@Controller('players')
@UseGuards(JwtAuthGuard)
export class PlayersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly tournamentsService: TournamentsService,
  ) {}

  @Get()
  async list() {
    const users = await this.usersService.listPlayers();
    return users.map((u) => this.usersService.toPlayerJson(u));
  }

  @Get('ranking')
  async ranking() {
    const users = await this.usersService.listPlayers();
    return users.map((u) => this.usersService.toPlayerJson(u));
  }

  @Get(':id')
  async byId(@Param('id') id: string) {
    const user = await this.usersService.getPlayerByPublicId(id);
    const history = await this.tournamentsService.tournamentHistoryForPlayer(
      user.publicId ?? user._id.toString(),
    );
    return this.usersService.toProfileJson(user, history);
  }
}
