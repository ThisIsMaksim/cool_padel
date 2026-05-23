import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

export class CreateGameDto {
  @IsObject()
  config!: Record<string, unknown>;

  @IsInt()
  @Min(0)
  servingTeamIndex!: number;

  @IsInt()
  @Min(0)
  servingPlayerIndex!: number;
}

export class UpdateStandardStateDto {
  @IsObject()
  standardState!: Record<string, unknown>;
}

export class UpdateTournamentStateDto {
  @IsObject()
  tournamentState!: Record<string, unknown>;
}

export class UpdateDeuceRuleDto {
  @IsEnum(['advantage', 'goldenPoint'])
  deuceRule!: 'advantage' | 'goldenPoint';
}

export class ListGamesQueryDto {
  @IsOptional()
  @IsEnum(['inProgress', 'finished'])
  status?: 'inProgress' | 'finished';
}

export class RegisterTournamentDto {
  @IsOptional()
  @IsString()
  partnerId?: string;
}

export class ListTournamentsQueryDto {
  @IsOptional()
  @IsString()
  day?: string;

  @IsOptional()
  @IsString()
  level?: string;

  @IsOptional()
  @IsString()
  club?: string;

  @IsOptional()
  @IsEnum(['singles', 'doubles'])
  format?: 'singles' | 'doubles';

  @IsOptional()
  @IsEnum(['open', 'full', 'finished'])
  status?: 'open' | 'full' | 'finished';
}

export class ToggleFavoriteResponseDto {
  @IsArray()
  @IsString({ each: true })
  favoriteIds!: string[];
}

export class BatchIdsDto {
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => String)
  ids?: string[];
}
