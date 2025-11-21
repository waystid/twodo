export type NoteAttachmentType = 'task' | 'event' | 'routine';

export interface Note {
  id: string;
  coupleId: string;
  content: string;
  attachedToType: NoteAttachmentType;
  attachedToId: string;
  createdById: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface NoteWithAuthor extends Note {
  author: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
}
