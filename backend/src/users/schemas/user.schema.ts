import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true, collection: 'users' })
export class User {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email!: string;

  @Prop()
  passwordHash?: string;

  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({ default: 1500 })
  rating!: number;

  @Prop({ default: 'B' })
  level!: string;

  @Prop({ default: '' })
  club!: string;

  @Prop({ default: '' })
  city!: string;

  @Prop({ required: true, enum: ['personal', 'club'], default: 'personal' })
  accountType!: 'personal' | 'club';

  @Prop()
  avatarColor?: number;

  /** Stable id for Flutter mock compatibility (player_1, etc.) */
  @Prop({ unique: true, sparse: true })
  publicId?: string;

  @Prop({ default: false })
  isSeedPlayer!: boolean;

  @Prop({ type: [String], default: [] })
  favoritePlayerIds!: string[];
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.virtual('id').get(function idGetter() {
  return this.publicId ?? this._id.toString();
});

UserSchema.set('toJSON', {
  virtuals: true,
  transform: (_doc, ret) => {
    const transformed = ret as unknown as Record<string, unknown>;
    transformed.id = ret.publicId ?? ret._id?.toString();
    delete transformed._id;
    delete transformed.__v;
    delete transformed.passwordHash;
    return transformed;
  },
});

UserSchema.set('toObject', { virtuals: true });
