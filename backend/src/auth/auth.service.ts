import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { TournamentsService } from '../tournaments/tournaments.service';
import { LoginDto, RegisterDto } from './dto/auth.dto';
import { AuthResponse } from './auth.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly tournamentsService: TournamentsService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    const existing = await this.usersService.findByEmail(dto.email);
    if (existing?.passwordHash) {
      throw new ConflictException('Email already registered');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);
    const isClub = dto.accountType === 'club';
    const trimmedName = dto.name.trim();
    const user =
      existing ??
      (await this.usersService.create({
        email: dto.email.toLowerCase(),
        name: trimmedName,
        rating: 1500,
        level: 'B',
        club: isClub ? trimmedName : '',
        city: '',
        accountType: dto.accountType,
        isSeedPlayer: false,
      }));

    user.name = trimmedName;
    user.passwordHash = passwordHash;
    user.isSeedPlayer = false;
    user.accountType = dto.accountType;
    if (isClub) {
      user.club = trimmedName;
    }
    if (!user.publicId) {
      user.publicId = `user_${Math.abs(this.hashCode(dto.email))}`;
    }
    await user.save();

    return this.buildAuthResponse(user);
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user?.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.buildAuthResponse(user);
  }

  async me(userId: string) {
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new UnauthorizedException();
    }
    const history = await this.tournamentsService.tournamentHistoryForPlayer(
      user.publicId ?? user._id.toString(),
    );
    return this.usersService.toProfileJson(user, history);
  }

  private async buildAuthResponse(user: {
    _id: { toString(): string };
    publicId?: string;
    email: string;
    name: string;
    save(): Promise<unknown>;
  }): Promise<AuthResponse> {
    const publicId = user.publicId ?? user._id.toString();
    const payload = { sub: user._id.toString(), email: user.email };
    const accessToken = await this.jwtService.signAsync(payload);
    const doc = await this.usersService.findById(user._id.toString());
    const history = doc
      ? await this.tournamentsService.tournamentHistoryForPlayer(publicId)
      : [];

    return {
      accessToken,
      user: doc
        ? this.usersService.toProfileJson(doc, history)
        : {
            id: publicId,
            name: user.name,
            email: user.email,
            rating: 1500,
            level: 'B',
            club: '',
            city: '',
            accountType: 'personal',
            tournamentHistory: history,
          },
    };
  }

  private hashCode(value: string) {
    let hash = 0;
    for (let i = 0; i < value.length; i++) {
      hash = (hash << 5) - hash + value.charCodeAt(i);
      hash |= 0;
    }
    return hash;
  }
}
