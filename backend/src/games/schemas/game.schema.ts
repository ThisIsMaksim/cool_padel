import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Schema as MongooseSchema } from 'mongoose';

export type GameDocument = HydratedDocument<Game>;

@Schema({ timestamps: true, collection: 'games' })
export class Game {
  @Prop({ required: true, index: true })
  ownerId!: string;

  @Prop({ required: true })
  createdAtIso!: string;

  @Prop({ required: true, enum: ['inProgress', 'finished'], index: true })
  status!: 'inProgress' | 'finished';

  @Prop({ type: MongooseSchema.Types.Mixed, required: true })
  config!: Record<string, unknown>;

  @Prop({ type: MongooseSchema.Types.Mixed })
  standardState?: Record<string, unknown>;

  @Prop({ type: MongooseSchema.Types.Mixed })
  tournamentState?: Record<string, unknown>;
}

export const GameSchema = SchemaFactory.createForClass(Game);

GameSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const transformed = ret as unknown as Record<string, unknown>;
    transformed.id = ret._id?.toString();
    delete transformed._id;
    delete transformed.__v;
    return transformed;
  },
});
