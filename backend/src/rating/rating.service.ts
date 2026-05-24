import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../users/schemas/user.schema';

@Injectable()
export class RatingService {
  private readonly kFactor = 32;

  constructor(@InjectModel(User.name) private readonly userModel: Model<UserDocument>) {}

  levelFromRating(rating: number): string {
    if (rating >= 1800) return 'A';
    if (rating >= 1700) return 'B+';
    if (rating >= 1600) return 'B';
    if (rating >= 1500) return 'C+';
    return 'C';
  }

  async applyMatchResult(params: {
    team1Ids: string[];
    team2Ids: string[];
    winnerIndex: number | null;
  }) {
    const { team1Ids, team2Ids, winnerIndex } = params;
    if (winnerIndex == null || team1Ids.length === 0 || team2Ids.length === 0) {
      return;
    }

    const team1Rating = await this.averageRating(team1Ids);
    const team2Rating = await this.averageRating(team2Ids);
    if (team1Rating == null || team2Rating == null) {
      return;
    }

    const expected1 = this.expectedScore(team1Rating, team2Rating);
    const score1 = winnerIndex === 0 ? 1 : 0;
    const delta1 = Math.round(this.kFactor * (score1 - expected1));
    const delta2 = -delta1;

    const winners = winnerIndex === 0 ? team1Ids : team2Ids;
    const losers = winnerIndex === 0 ? team2Ids : team1Ids;

    await this.adjustTeam(winners, delta1);
    await this.adjustTeam(losers, delta2);
  }

  private expectedScore(ratingA: number, ratingB: number) {
    return 1 / (1 + 10 ** ((ratingB - ratingA) / 400));
  }

  private async averageRating(publicIds: string[]) {
    const users = await this.userModel
      .find({ publicId: { $in: publicIds } })
      .select('rating publicId')
      .exec();
    if (users.length === 0) {
      return null;
    }
    const sum = users.reduce((acc, user) => acc + (user.rating ?? 1500), 0);
    return sum / users.length;
  }

  private async adjustTeam(publicIds: string[], delta: number) {
    for (const publicId of publicIds) {
      const user = await this.userModel.findOne({ publicId }).exec();
      if (!user) {
        continue;
      }
      user.rating = Math.max(1000, (user.rating ?? 1500) + delta);
      user.level = this.levelFromRating(user.rating);
      await user.save();
    }
  }
}
