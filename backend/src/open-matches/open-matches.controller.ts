import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AuthUser } from '../auth/auth.types';
import { CreateOpenMatchDto } from '../common/dto/api.dto';
import { OpenMatchesService } from './open-matches.service';

@Controller('open-matches')
@UseGuards(JwtAuthGuard)
export class OpenMatchesController {
  constructor(private readonly openMatchesService: OpenMatchesService) {}

  @Get()
  list() {
    return this.openMatchesService.list();
  }

  @Get('mine')
  mine(@CurrentUser() user: AuthUser) {
    return this.openMatchesService.mine(user.publicId);
  }

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateOpenMatchDto) {
    return this.openMatchesService.create(user.publicId, dto);
  }

  @Patch(':id/join')
  join(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.openMatchesService.join(id, user.publicId);
  }

  @Patch(':id/cancel')
  cancel(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.openMatchesService.cancel(id, user.publicId);
  }
}
