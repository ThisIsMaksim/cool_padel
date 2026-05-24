import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type OpenMatchDocument = HydratedDocument<OpenMatch>;

@Schema({ timestamps: true, collection: 'open_matches' })
export class OpenMatch {
  @Prop({ required: true, unique: true })
  publicId!: string;

  @Prop({ required: true })
  creatorId!: string;

  @Prop({ required: true })
  club!: string;

  @Prop({ default: '' })
  address!: string;

  @Prop({ required: true })
  dateTime!: Date;

  @Prop({ required: true })
  level!: string;

  @Prop({ required: true, enum: ['singles', 'doubles'] })
  format!: 'singles' | 'doubles';

  @Prop({ required: true })
  maxPlayers!: number;

  @Prop()
  note?: string;

  @Prop({ type: [String], default: [] })
  participantIds!: string[];

  @Prop({ required: true, enum: ['open', 'full', 'cancelled'], default: 'open' })
  status!: 'open' | 'full' | 'cancelled';
}

export const OpenMatchSchema = SchemaFactory.createForClass(OpenMatch);

OpenMatchSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const transformed = ret as unknown as Record<string, unknown>;
    transformed.id = ret.publicId;
    delete transformed._id;
    delete transformed.__v;
    delete transformed.publicId;
    return transformed;
  },
});
