import { z } from 'zod';

export const noteAttachmentTypeSchema = z.enum(['task', 'event', 'routine']);

export const createNoteSchema = z.object({
  content: z.string().min(1, 'Note content is required').max(5000),
  attachedToType: noteAttachmentTypeSchema,
  attachedToId: z.string().uuid('Invalid entity ID'),
});

export const updateNoteSchema = z.object({
  content: z.string().min(1, 'Note content is required').max(5000),
});

export type CreateNoteInput = z.infer<typeof createNoteSchema>;
export type UpdateNoteInput = z.infer<typeof updateNoteSchema>;
