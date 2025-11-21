import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { noteApi } from '../lib/note-api';
import { useAuth } from '../hooks/useAuth';
import type { NoteAttachmentType, Note } from '@twodo/shared';

interface NotesProps {
  attachedToType: NoteAttachmentType;
  attachedToId: string;
}

export function Notes({ attachedToType, attachedToId }: NotesProps) {
  const [noteContent, setNoteContent] = useState('');
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);
  const [editContent, setEditContent] = useState('');
  const queryClient = useQueryClient();
  const { user } = useAuth();

  // Fetch notes
  const { data: notesData, isLoading } = useQuery({
    queryKey: ['notes', attachedToType, attachedToId],
    queryFn: () => noteApi.getNotes(attachedToType, attachedToId),
  });

  // Create note mutation
  const createNoteMutation = useMutation({
    mutationFn: (content: string) =>
      noteApi.createNote({
        content,
        attachedToType,
        attachedToId,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notes', attachedToType, attachedToId] });
      setNoteContent('');
    },
  });

  // Update note mutation
  const updateNoteMutation = useMutation({
    mutationFn: ({ noteId, content }: { noteId: string; content: string }) =>
      noteApi.updateNote(noteId, { content }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notes', attachedToType, attachedToId] });
      setEditingNoteId(null);
      setEditContent('');
    },
  });

  // Delete note mutation
  const deleteNoteMutation = useMutation({
    mutationFn: (noteId: string) => noteApi.deleteNote(noteId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notes', attachedToType, attachedToId] });
    },
  });

  const notes = notesData?.notes || [];

  const handleCreateNote = () => {
    if (!noteContent.trim()) return;
    createNoteMutation.mutate(noteContent);
  };

  const handleUpdateNote = (noteId: string) => {
    if (!editContent.trim()) return;
    updateNoteMutation.mutate({ noteId, content: editContent });
  };

  const startEdit = (note: Note) => {
    setEditingNoteId(note.id);
    setEditContent(note.content);
  };

  const cancelEdit = () => {
    setEditingNoteId(null);
    setEditContent('');
  };

  const formatTime = (date: Date | string) => {
    const d = new Date(date);
    const now = new Date();
    const diffMs = now.getTime() - d.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return d.toLocaleDateString();
  };

  if (isLoading) {
    return <div className="text-sm text-gray-500">Loading notes...</div>;
  }

  return (
    <div className="space-y-4">
      <h3 className="text-sm font-semibold text-gray-700">Notes</h3>

      {/* Note list */}
      <div className="space-y-3">
        {notes.length === 0 ? (
          <p className="text-sm text-gray-500 italic">No notes yet</p>
        ) : (
          notes.map((note: any) => (
            <div key={note.id} className="bg-gray-50 rounded-lg p-3 border">
              {editingNoteId === note.id ? (
                // Edit mode
                <div className="space-y-2">
                  <textarea
                    className="w-full px-3 py-2 border rounded text-sm"
                    value={editContent}
                    onChange={(e) => setEditContent(e.target.value)}
                    rows={3}
                    autoFocus
                  />
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleUpdateNote(note.id)}
                      disabled={!editContent.trim()}
                      className="text-xs px-3 py-1 bg-primary-600 text-white rounded hover:bg-primary-700 disabled:opacity-50"
                    >
                      Save
                    </button>
                    <button
                      onClick={cancelEdit}
                      className="text-xs px-3 py-1 border rounded hover:bg-gray-50"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                // View mode
                <>
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex-1">
                      <p className="text-sm text-gray-900 whitespace-pre-wrap">{note.content}</p>
                      <div className="flex items-center gap-2 mt-2 text-xs text-gray-500">
                        <span className="font-medium">{note.createdBy?.displayName}</span>
                        <span>•</span>
                        <span>{formatTime(note.createdAt)}</span>
                        {note.updatedAt !== note.createdAt && <span>(edited)</span>}
                      </div>
                    </div>
                    {user?.id === note.createdById && (
                      <div className="flex gap-1">
                        <button
                          onClick={() => startEdit(note)}
                          className="text-xs text-primary-600 hover:text-primary-700 px-2 py-1"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => {
                            if (confirm('Delete this note?')) {
                              deleteNoteMutation.mutate(note.id);
                            }
                          }}
                          className="text-xs text-red-600 hover:text-red-700 px-2 py-1"
                        >
                          Delete
                        </button>
                      </div>
                    )}
                  </div>
                </>
              )}
            </div>
          ))
        )}
      </div>

      {/* Add note form */}
      <div className="space-y-2">
        <textarea
          className="w-full px-3 py-2 border rounded text-sm"
          placeholder="Add a note..."
          value={noteContent}
          onChange={(e) => setNoteContent(e.target.value)}
          rows={3}
        />
        <button
          onClick={handleCreateNote}
          disabled={!noteContent.trim() || createNoteMutation.isPending}
          className="px-4 py-2 bg-primary-600 text-white rounded text-sm hover:bg-primary-700 disabled:opacity-50"
        >
          {createNoteMutation.isPending ? 'Adding...' : 'Add Note'}
        </button>
      </div>
    </div>
  );
}
