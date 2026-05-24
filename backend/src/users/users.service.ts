import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private readonly userModel: Model<UserDocument>) {}

  create(data: Partial<User>) {
    return this.userModel.create(data);
  }

  findByEmail(email: string) {
    return this.userModel.findOne({ email: email.toLowerCase() }).exec();
  }

  findById(id: string) {
    return this.userModel.findById(id).exec();
  }

  findByPublicId(publicId: string) {
    return this.userModel.findOne({ publicId }).exec();
  }

  findAllPlayers() {
    return this.userModel
      .find({ $or: [{ isSeedPlayer: true }, { publicId: { $exists: true } }] })
      .sort({ rating: -1 })
      .exec();
  }

  listPlayers() {
    return this.userModel.find().sort({ rating: -1 }).exec();
  }

  async getPlayerByPublicId(publicId: string) {
    const user = await this.userModel
      .findOne({ $or: [{ publicId }, { _id: publicId }] })
      .exec();
    if (!user) {
      throw new NotFoundException('Player not found');
    }
    return user;
  }

  async updateProfile(userId: string, patch: Partial<User>) {
    const user = await this.userModel
      .findByIdAndUpdate(userId, patch, { new: true })
      .exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async toggleFavorite(userId: string, playerId: string) {
    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const favorites = new Set(user.favoritePlayerIds);
    if (favorites.has(playerId)) {
      favorites.delete(playerId);
    } else {
      favorites.add(playerId);
    }

    user.favoritePlayerIds = [...favorites];
    await user.save();
    return user.favoritePlayerIds;
  }

  async getFavorites(userId: string) {
    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user.favoritePlayerIds;
  }

  toPlayerJson(user: UserDocument) {
    return {
      id: user.publicId ?? user._id.toString(),
      name: user.name,
      rating: user.rating,
      level: user.level,
      club: user.club,
      city: user.city,
      avatarColor: user.avatarColor ?? null,
    };
  }

  toProfileJson(
    user: UserDocument,
    tournamentHistory: string[] = [],
  ) {
    return {
      id: user.publicId ?? user._id.toString(),
      name: user.name,
      email: user.email,
      rating: user.rating,
      level: user.level,
      club: user.club,
      city: user.city,
      accountType: user.accountType ?? 'personal',
      tournamentHistory,
    };
  }
}
