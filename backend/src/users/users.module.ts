import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from './schemas/user.schema';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TournamentsModule } from '../tournaments/tournaments.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
    forwardRef(() => TournamentsModule),
  ],
  providers: [UsersService],
  controllers: [UsersController],
  exports: [UsersService, MongooseModule],
})
export class UsersModule {}
