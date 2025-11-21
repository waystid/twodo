import { apiClient } from './api';
import type { Note, CreateNoteInput, UpdateNoteInput, NoteAttachmentType } from '@twodo/shared';

export const noteApi = {
  async getNotes(type: NoteAttachmentType, entityId: string): Promise<{ notes: Note[] }> {
    return apiClient.get(`/notes/${type}/${entityId}`);
  },

  async getNote(noteId: string): Promise<{ note: Note }> {
    return apiClient.get(`/notes/${noteId}`);
  },

  async createNote(data: CreateNoteInput): Promise<{ note: Note }> {
    return apiClient.post('/notes', data);
  },

  async updateNote(noteId: string, data: UpdateNoteInput): Promise<{ note: Note }> {
    return apiClient.put(`/notes/${noteId}`, data);
  },

  async deleteNote(noteId: string): Promise<{ success: boolean }> {
    return apiClient.delete(`/notes/${noteId}`);
  },
};
