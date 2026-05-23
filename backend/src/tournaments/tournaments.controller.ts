import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AuthUser } from '../auth/auth.types';
import {
  ListTournamentsQueryDto,
  RegisterTournamentDto,
} from '../common/dto/api.dto';
import { TournamentsService } from './tournaments.service';

@Controller('tournaments')
@UseGuards(JwtAuthGuard)
export class TournamentsController {
  constructor(private readonly tournamentsService: TournamentsService) {}

  @Get()
  list(@Query() query: ListTournamentsQueryDto) {
    return this.tournamentsService.list(query);
  }

  @Get('active')
  active() {
    return this.tournamentsService.active();
  }

  @Get(':id')
  byId(@Param('id') id: string) {
    return this.tournamentsService.byId(id);
  }

  @Post(':id/register')
  register(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: RegisterTournamentDto,
  ) {
    return this.tournamentsService.register(id, user.publicId, dto);
  }
}
