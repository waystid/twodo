export type NotificationType =
  | 'task_due'
  | 'event_reminder'
  | 'routine_due'
  | 'task_assigned'
  | 'note_added';

export interface Notification {
  id: string;
  userId: string;
  coupleId: string;
  type: NotificationType;
  title: string;
  body: string;
  relatedEntityType?: string;
  relatedEntityId?: string;
  isRead: boolean;
  sentAt?: Date;
  createdAt: Date;
}
