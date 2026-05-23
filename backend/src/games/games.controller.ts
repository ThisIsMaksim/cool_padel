import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AuthUser } from '../auth/auth.types';
import {
  CreateGameDto,
  ListGamesQueryDto,
  UpdateDeuceRuleDto,
  UpdateStandardStateDto,
  UpdateTournamentStateDto,
} from '../common/dto/api.dto';
import { GamesService } from './games.service';

@Controller('games')
@UseGuards(JwtAuthGuard)
export class GamesController {
  constructor(private readonly gamesService: GamesService) {}

  @Get()
  list(@CurrentUser() user: AuthUser, @Query() query: ListGamesQueryDto) {
    return this.gamesService.list(user.userId, query.status);
  }

  @Get(':id')
  get(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.gamesService.getById(user.userId, id);
  }

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateGameDto) {
    return this.gamesService.create(user.userId, dto);
  }

  @Patch(':id/standard-state')
  updateStandard(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateStandardStateDto,
  ) {
    return this.gamesService.updateStandardState(user.userId, id, dto);
  }

  @Patch(':id/tournament-state')
  updateTournament(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateTournamentStateDto,
  ) {
    return this.gamesService.updateTournamentState(user.userId, id, dto);
  }

  @Patch(':id/deuce-rule')
  updateDeuce(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateDeuceRuleDto,
  ) {
    return this.gamesService.updateDeuceRule(user.userId, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.gamesService.remove(user.userId, id);
  }
}
