import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Notification, NotificationDocument } from './schemas/notification.schema';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name)
    private readonly notificationModel: Model<NotificationDocument>,
  ) {}

  list(userPublicId: string) {
    return this.notificationModel
      .find({ userPublicId })
      .sort({ createdAt: -1 })
      .limit(50)
      .exec()
      .then((items) => items.map((n) => this.toClientJson(n)));
  }

  unreadCount(userPublicId: string) {
    return this.notificationModel
      .countDocuments({ userPublicId, read: false })
      .exec();
  }

  async create(params: {
    userPublicId: string;
    type: string;
    title: string;
    body: string;
    linkPath?: string;
  }) {
    const notification = await this.notificationModel.create({
      ...params,
      read: false,
    });
    return this.toClientJson(notification);
  }

  async createMany(
    userPublicIds: string[],
    payload: Omit<Parameters<NotificationsService['create']>[0], 'userPublicId'>,
  ) {
    const unique = [...new Set(userPublicIds.filter(Boolean))];
    await Promise.all(
      unique.map((userPublicId) =>
        this.create({ userPublicId, ...payload }),
      ),
    );
  }

  async markRead(userPublicId: string, id: string) {
    await this.notificationModel
      .updateOne(
        { _id: id, userPublicId },
        { $set: { read: true } },
      )
      .exec();
    return { ok: true };
  }

  async markAllRead(userPublicId: string) {
    await this.notificationModel
      .updateMany({ userPublicId }, { $set: { read: true } })
      .exec();
    return { ok: true };
  }

  private toClientJson(notification: NotificationDocument) {
    const doc = notification as NotificationDocument & { createdAt?: Date };
    return {
      id: notification._id.toString(),
      type: notification.type,
      title: notification.title,
      body: notification.body,
      linkPath: notification.linkPath,
      read: notification.read,
      createdAt: doc.createdAt?.toISOString() ?? new Date().toISOString(),
    };
  }
}
