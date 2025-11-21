import { db, notes } from '@twodo/database';
import { eq, and, desc } from 'drizzle-orm';
import type { CreateNoteInput, UpdateNoteInput } from '@twodo/shared';
import { NotFoundError } from '../utils/errors';

export class NoteService {
  // Create note
  static async createNote(coupleId: string, userId: string, input: CreateNoteInput) {
    const [note] = await db
      .insert(notes)
      .values({
        ...input,
        coupleId,
        createdById: userId,
      })
      .returning();

    return note;
  }

  // Get notes for an entity
  static async getNotes(coupleId: string, attachedToType: string, attachedToId: string) {
    const noteList = await db.query.notes.findMany({
      where: and(
        eq(notes.coupleId, coupleId),
        eq(notes.attachedToType, attachedToType as any),
        eq(notes.attachedToId, attachedToId)
      ),
      orderBy: [desc(notes.createdAt)],
      with: {
        createdBy: {
          columns: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    return noteList;
  }

  // Get single note
  static async getNote(noteId: string, coupleId: string) {
    const note = await db.query.notes.findFirst({
      where: and(eq(notes.id, noteId), eq(notes.coupleId, coupleId)),
      with: {
        createdBy: {
          columns: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    if (!note) {
      throw new NotFoundError('Note not found');
    }

    return note;
  }

  // Update note
  static async updateNote(noteId: string, coupleId: string, userId: string, input: UpdateNoteInput) {
    const note = await db.query.notes.findFirst({
      where: and(eq(notes.id, noteId), eq(notes.coupleId, coupleId)),
    });

    if (!note) {
      throw new NotFoundError('Note not found');
    }

    // Only the author can update their note
    if (note.createdById !== userId) {
      throw new NotFoundError('You can only edit your own notes');
    }

    const [updated] = await db
      .update(notes)
      .set({
        content: input.content,
        updatedAt: new Date(),
      })
      .where(eq(notes.id, noteId))
      .returning();

    return updated;
  }

  // Delete note
  static async deleteNote(noteId: string, coupleId: string, userId: string) {
    const note = await db.query.notes.findFirst({
      where: and(eq(notes.id, noteId), eq(notes.coupleId, coupleId)),
    });

    if (!note) {
      throw new NotFoundError('Note not found');
    }

    // Only the author can delete their note
    if (note.createdById !== userId) {
      throw new NotFoundError('You can only delete your own notes');
    }

    await db.delete(notes).where(eq(notes.id, noteId));

    return { success: true };
  }
}
