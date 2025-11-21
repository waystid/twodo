import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useAuth } from '../hooks/useAuth';
import { coupleApi } from '../lib/couple-api';
import { taskApi } from '../lib/task-api';
import type { TaskList, Task } from '@twodo/shared';

export function DashboardPage() {
  const { user, logout } = useAuth();
  const queryClient = useQueryClient();
  const [selectedListId, setSelectedListId] = useState<string | null>(null);
  const [showNewListForm, setShowNewListForm] = useState(false);
  const [showNewTaskForm, setShowNewTaskForm] = useState(false);
  const [newListName, setNewListName] = useState('');
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [inviteCode, setInviteCode] = useState('');

  // Fetch couple
  const { data: coupleData } = useQuery({
    queryKey: ['couple'],
    queryFn: () => coupleApi.getMyCouple(),
  });

  // Fetch task lists
  const { data: listsData } = useQuery({
    queryKey: ['taskLists'],
    queryFn: () => taskApi.getTaskLists(),
  });

  // Fetch tasks
  const { data: tasksData } = useQuery({
    queryKey: ['tasks', selectedListId],
    queryFn: () => taskApi.getTasks(selectedListId || undefined),
  });

  // Create list mutation
  const createListMutation = useMutation({
    mutationFn: (name: string) => taskApi.createTaskList({ name }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['taskLists'] });
      setNewListName('');
      setShowNewListForm(false);
    },
  });

  // Create task mutation
  const createTaskMutation = useMutation({
    mutationFn: (title: string) =>
      taskApi.createTask({
        listId: selectedListId!,
        title,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
      setNewTaskTitle('');
      setShowNewTaskForm(false);
    },
  });

  // Complete task mutation
  const completeTaskMutation = useMutation({
    mutationFn: ({ taskId, completed }: { taskId: string; completed: boolean }) =>
      taskApi.completeTask(taskId, completed),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });

  // Generate invite code mutation
  const generateInviteMutation = useMutation({
    mutationFn: () => coupleApi.generateInviteCode(user?.coupleId!),
    onSuccess: (data) => {
      setInviteCode(data.inviteCode);
    },
  });

  const handleLogout = async () => {
    await logout();
    window.location.href = '/login';
  };

  const couple = coupleData?.couple;
  const lists = listsData?.lists || [];
  const tasks = tasksData?.tasks || [];
  const selectedList = lists.find((l) => l.id === selectedListId);
  const partnerCount = couple?.members?.length || 0;

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <div className="w-64 bg-white shadow-lg flex flex-col">
        <div className="p-4 border-b">
          <h1 className="text-2xl font-bold text-gray-900">TwoDo</h1>
          <p className="text-sm text-gray-600">{couple?.name}</p>
        </div>

        {/* Lists */}
        <div className="flex-1 overflow-y-auto p-4">
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-sm font-semibold text-gray-700 uppercase">Lists</h2>
            <button
              onClick={() => setShowNewListForm(true)}
              className="text-primary-600 hover:text-primary-700 text-xl"
            >
              +
            </button>
          </div>

          {showNewListForm && (
            <div className="mb-3">
              <input
                type="text"
                placeholder="List name"
                className="w-full px-2 py-1 text-sm border rounded"
                value={newListName}
                onChange={(e) => setNewListName(e.target.value)}
                onKeyPress={(e) => {
                  if (e.key === 'Enter' && newListName) {
                    createListMutation.mutate(newListName);
                  }
                }}
                autoFocus
              />
              <div className="flex gap-2 mt-1">
                <button
                  onClick={() => createListMutation.mutate(newListName)}
                  disabled={!newListName}
                  className="text-xs px-2 py-1 bg-primary-600 text-white rounded disabled:opacity-50"
                >
                  Add
                </button>
                <button
                  onClick={() => {
                    setShowNewListForm(false);
                    setNewListName('');
                  }}
                  className="text-xs px-2 py-1 border rounded"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}

          <div className="space-y-1">
            <button
              onClick={() => setSelectedListId(null)}
              className={`w-full text-left px-3 py-2 rounded text-sm ${
                selectedListId === null
                  ? 'bg-primary-50 text-primary-700 font-medium'
                  : 'hover:bg-gray-100'
              }`}
            >
              All Tasks
            </button>
            {lists.map((list) => (
              <button
                key={list.id}
                onClick={() => setSelectedListId(list.id)}
                className={`w-full text-left px-3 py-2 rounded text-sm ${
                  selectedListId === list.id
                    ? 'bg-primary-50 text-primary-700 font-medium'
                    : 'hover:bg-gray-100'
                }`}
              >
                {list.name}
              </button>
            ))}
          </div>
        </div>

        {/* User menu */}
        <div className="border-t p-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-700">{user?.displayName}</span>
          </div>
          {partnerCount < 2 && (
            <button
              onClick={() => {
                setShowInviteModal(true);
                generateInviteMutation.mutate();
              }}
              className="w-full mb-2 text-xs px-3 py-2 bg-primary-600 text-white rounded hover:bg-primary-700"
            >
              Invite Partner
            </button>
          )}
          <button
            onClick={handleLogout}
            className="w-full text-xs px-3 py-2 border rounded hover:bg-gray-50"
          >
            Logout
          </button>
        </div>
      </div>

      {/* Main content */}
      <div className="flex-1 flex flex-col">
        {/* Header */}
        <div className="bg-white shadow-sm p-6 border-b">
          <h2 className="text-2xl font-bold text-gray-900">
            {selectedList ? selectedList.name : 'All Tasks'}
          </h2>
          <p className="text-sm text-gray-600 mt-1">
            {tasks.length} {tasks.length === 1 ? 'task' : 'tasks'}
          </p>
        </div>

        {/* Tasks */}
        <div className="flex-1 overflow-y-auto p-6">
          {selectedListId && (
            <div className="mb-4">
              {showNewTaskForm ? (
                <div className="bg-white rounded-lg shadow-sm p-4">
                  <input
                    type="text"
                    placeholder="Task title"
                    className="w-full px-3 py-2 border rounded mb-2"
                    value={newTaskTitle}
                    onChange={(e) => setNewTaskTitle(e.target.value)}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter' && newTaskTitle) {
                        createTaskMutation.mutate(newTaskTitle);
                      }
                    }}
                    autoFocus
                  />
                  <div className="flex gap-2">
                    <button
                      onClick={() => createTaskMutation.mutate(newTaskTitle)}
                      disabled={!newTaskTitle}
                      className="px-4 py-2 bg-primary-600 text-white rounded text-sm disabled:opacity-50"
                    >
                      Add Task
                    </button>
                    <button
                      onClick={() => {
                        setShowNewTaskForm(false);
                        setNewTaskTitle('');
                      }}
                      className="px-4 py-2 border rounded text-sm"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <button
                  onClick={() => setShowNewTaskForm(true)}
                  className="w-full px-4 py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-600 hover:border-primary-400 hover:text-primary-600 text-sm font-medium"
                >
                  + Add Task
                </button>
              )}
            </div>
          )}

          {!selectedListId && lists.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-600 mb-4">No task lists yet. Create your first list!</p>
            </div>
          )}

          {selectedListId && tasks.length === 0 && !showNewTaskForm && (
            <div className="text-center py-12">
              <p className="text-gray-600">No tasks in this list yet.</p>
            </div>
          )}

          <div className="space-y-2">
            {tasks.map((task) => (
              <div
                key={task.id}
                className="bg-white rounded-lg shadow-sm p-4 hover:shadow-md transition"
              >
                <div className="flex items-start gap-3">
                  <input
                    type="checkbox"
                    checked={task.status === 'completed'}
                    onChange={(e) =>
                      completeTaskMutation.mutate({
                        taskId: task.id,
                        completed: e.target.checked,
                      })
                    }
                    className="mt-1 h-5 w-5 rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                  />
                  <div className="flex-1">
                    <h3
                      className={`font-medium ${
                        task.status === 'completed' ? 'line-through text-gray-500' : 'text-gray-900'
                      }`}
                    >
                      {task.title}
                    </h3>
                    {task.description && (
                      <p className="text-sm text-gray-600 mt-1">{task.description}</p>
                    )}
                    {task.dueDate && (
                      <p className="text-xs text-gray-500 mt-1">
                        Due: {new Date(task.dueDate).toLocaleDateString()}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Invite Modal */}
      {showInviteModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
            <h3 className="text-xl font-bold mb-4">Invite Your Partner</h3>
            <p className="text-gray-600 mb-4">
              Share this code with your partner so they can join your couple:
            </p>
            {generateInviteMutation.isPending ? (
              <div className="text-center py-4">
                <div className="animate-spin h-8 w-8 border-4 border-primary-600 border-t-transparent rounded-full mx-auto"></div>
              </div>
            ) : inviteCode ? (
              <>
                <div className="bg-gray-100 rounded p-4 mb-4">
                  <code className="text-2xl font-mono font-bold text-center block">
                    {inviteCode}
                  </code>
                </div>
                <p className="text-sm text-gray-500 mb-4">This code expires in 48 hours.</p>
                <button
                  onClick={() => {
                    navigator.clipboard.writeText(inviteCode);
                  }}
                  className="w-full py-2 px-4 bg-primary-600 text-white rounded hover:bg-primary-700"
                >
                  Copy Code
                </button>
              </>
            ) : null}
            <button
              onClick={() => {
                setShowInviteModal(false);
                setInviteCode('');
              }}
              className="w-full mt-3 py-2 px-4 border rounded hover:bg-gray-50"
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
