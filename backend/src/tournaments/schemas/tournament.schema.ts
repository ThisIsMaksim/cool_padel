import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type TournamentDocument = HydratedDocument<Tournament>;

@Schema({ timestamps: true, collection: 'tournaments' })
export class Tournament {
  @Prop({ required: true, unique: true })
  publicId!: string;

  @Prop({ required: true })
  title!: string;

  @Prop({ required: true })
  description!: string;

  @Prop({ required: true })
  club!: string;

  @Prop({ required: true })
  address!: string;

  @Prop({ required: true })
  dateTime!: Date;

  @Prop({ required: true })
  level!: string;

  @Prop({ required: true, enum: ['singles', 'doubles'] })
  format!: 'singles' | 'doubles';

  @Prop({ required: true })
  maxParticipants!: number;

  @Prop({ required: true })
  organizerId!: string;

  @Prop({ type: [String], default: [] })
  participantIds!: string[];

  @Prop({ type: [String], default: [] })
  waitlistIds!: string[];

  @Prop({ required: true, enum: ['open', 'full', 'finished'], default: 'open' })
  status!: 'open' | 'full' | 'finished';
}

export const TournamentSchema = SchemaFactory.createForClass(Tournament);

TournamentSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const transformed = ret as unknown as Record<string, unknown>;
    transformed.id = ret.publicId;
    delete transformed._id;
    delete transformed.__v;
    delete transformed.publicId;
    return transformed;
  },
});
