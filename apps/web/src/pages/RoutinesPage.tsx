import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useAuth } from '../hooks/useAuth';
import { routineApi } from '../lib/routine-api';
import type { Routine, CreateRoutineInput, RoutineSchedule } from '@twodo/shared';

export function RoutinesPage() {
  const { user, logout } = useAuth();
  const queryClient = useQueryClient();
  const [showNewRoutineForm, setShowNewRoutineForm] = useState(false);
  const [selectedRoutineId, setSelectedRoutineId] = useState<string | null>(null);

  // Form state
  const [routineName, setRoutineName] = useState('');
  const [routineDescription, setRoutineDescription] = useState('');
  const [frequency, setFrequency] = useState<'daily' | 'weekly' | 'monthly'>('weekly');
  const [daysOfWeek, setDaysOfWeek] = useState<number[]>([]);
  const [dayOfMonth, setDayOfMonth] = useState<number>(1);

  // Fetch routines
  const { data: routinesData } = useQuery({
    queryKey: ['routines'],
    queryFn: () => routineApi.getRoutines(),
  });

  // Fetch occurrences for selected routine
  const { data: occurrencesData } = useQuery({
    queryKey: ['routineOccurrences', selectedRoutineId],
    queryFn: () => {
      if (!selectedRoutineId) return null;
      const today = new Date();
      const thirtyDaysAgo = new Date(today);
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      return routineApi.getOccurrences(
        selectedRoutineId,
        thirtyDaysAgo.toISOString(),
        today.toISOString()
      );
    },
    enabled: !!selectedRoutineId,
  });

  // Fetch stats for selected routine
  const { data: statsData } = useQuery({
    queryKey: ['routineStats', selectedRoutineId],
    queryFn: () => (selectedRoutineId ? routineApi.getRoutineStats(selectedRoutineId) : null),
    enabled: !!selectedRoutineId,
  });

  // Create routine mutation
  const createRoutineMutation = useMutation({
    mutationFn: (data: CreateRoutineInput) => routineApi.createRoutine(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routines'] });
      resetForm();
    },
  });

  // Complete occurrence mutation
  const completeOccurrenceMutation = useMutation({
    mutationFn: ({ routineId, occurrenceId }: { routineId: string; occurrenceId: string }) =>
      routineApi.completeOccurrence(routineId, occurrenceId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routineOccurrences'] });
      queryClient.invalidateQueries({ queryKey: ['routineStats'] });
    },
  });

  const resetForm = () => {
    setShowNewRoutineForm(false);
    setRoutineName('');
    setRoutineDescription('');
    setFrequency('weekly');
    setDaysOfWeek([]);
    setDayOfMonth(1);
  };

  const handleCreateRoutine = () => {
    const schedule: RoutineSchedule = {
      frequency,
      ...(frequency === 'weekly' && { daysOfWeek }),
      ...(frequency === 'monthly' && { dayOfMonth }),
    };

    createRoutineMutation.mutate({
      name: routineName,
      description: routineDescription || undefined,
      schedule,
    });
  };

  const toggleDayOfWeek = (day: number) => {
    setDaysOfWeek((prev) =>
      prev.includes(day) ? prev.filter((d) => d !== day) : [...prev, day].sort()
    );
  };

  const handleLogout = async () => {
    await logout();
    window.location.href = '/login';
  };

  const routines = routinesData?.routines || [];
  const occurrences = occurrencesData?.occurrences || [];
  const stats = statsData?.stats;
  const selectedRoutine = routines.find((r) => r.id === selectedRoutineId);

  const daysOfWeekNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <div className="flex items-center space-x-4">
            <button onClick={() => (window.location.href = '/dashboard')} className="text-gray-600 hover:text-gray-900">
              ← Back to Dashboard
            </button>
            <h1 className="text-2xl font-bold text-gray-900">Routines</h1>
          </div>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-600">Welcome, {user?.displayName}!</span>
            <button onClick={handleLogout} className="px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900">
              Logout
            </button>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Routines List */}
          <div className="md:col-span-1">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-lg font-semibold">Your Routines</h2>
                <button
                  onClick={() => setShowNewRoutineForm(true)}
                  className="text-primary-600 hover:text-primary-700 text-2xl"
                >
                  +
                </button>
              </div>

              {showNewRoutineForm && (
                <div className="mb-4 p-4 border rounded-lg">
                  <input
                    type="text"
                    placeholder="Routine name"
                    className="w-full px-3 py-2 border rounded mb-2"
                    value={routineName}
                    onChange={(e) => setRoutineName(e.target.value)}
                  />
                  <textarea
                    placeholder="Description (optional)"
                    className="w-full px-3 py-2 border rounded mb-2 text-sm"
                    rows={2}
                    value={routineDescription}
                    onChange={(e) => setRoutineDescription(e.target.value)}
                  />

                  <label className="block text-sm font-medium text-gray-700 mb-1">Frequency</label>
                  <select
                    className="w-full px-3 py-2 border rounded mb-2"
                    value={frequency}
                    onChange={(e) => setFrequency(e.target.value as any)}
                  >
                    <option value="daily">Daily</option>
                    <option value="weekly">Weekly</option>
                    <option value="monthly">Monthly</option>
                  </select>

                  {frequency === 'weekly' && (
                    <div className="mb-2">
                      <label className="block text-sm font-medium text-gray-700 mb-1">Days of Week</label>
                      <div className="flex gap-1">
                        {daysOfWeekNames.map((day, index) => (
                          <button
                            key={index}
                            onClick={() => toggleDayOfWeek(index)}
                            className={`flex-1 py-1 text-xs rounded ${
                              daysOfWeek.includes(index)
                                ? 'bg-primary-600 text-white'
                                : 'bg-gray-100 text-gray-700'
                            }`}
                          >
                            {day}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {frequency === 'monthly' && (
                    <div className="mb-2">
                      <label className="block text-sm font-medium text-gray-700 mb-1">Day of Month</label>
                      <input
                        type="number"
                        min="1"
                        max="31"
                        className="w-full px-3 py-2 border rounded"
                        value={dayOfMonth}
                        onChange={(e) => setDayOfMonth(parseInt(e.target.value))}
                      />
                    </div>
                  )}

                  <div className="flex gap-2">
                    <button
                      onClick={handleCreateRoutine}
                      disabled={!routineName || (frequency === 'weekly' && daysOfWeek.length === 0)}
                      className="flex-1 px-4 py-2 bg-primary-600 text-white rounded text-sm disabled:opacity-50"
                    >
                      Create
                    </button>
                    <button onClick={resetForm} className="px-4 py-2 border rounded text-sm">
                      Cancel
                    </button>
                  </div>
                </div>
              )}

              <div className="space-y-2">
                {routines.map((routine) => (
                  <button
                    key={routine.id}
                    onClick={() => setSelectedRoutineId(routine.id)}
                    className={`w-full text-left px-3 py-2 rounded ${
                      selectedRoutineId === routine.id
                        ? 'bg-primary-50 text-primary-700 font-medium'
                        : 'hover:bg-gray-100'
                    }`}
                  >
                    {routine.name}
                  </button>
                ))}
                {routines.length === 0 && !showNewRoutineForm && (
                  <p className="text-sm text-gray-500 text-center py-4">No routines yet</p>
                )}
              </div>
            </div>
          </div>

          {/* Routine Details */}
          <div className="md:col-span-2">
            {selectedRoutine ? (
              <div>
                {/* Stats */}
                <div className="bg-white rounded-lg shadow p-6 mb-6">
                  <h2 className="text-xl font-bold mb-4">{selectedRoutine.name}</h2>
                  {selectedRoutine.description && (
                    <p className="text-gray-600 mb-4">{selectedRoutine.description}</p>
                  )}

                  {stats && (
                    <div className="grid grid-cols-4 gap-4 mb-4">
                      <div className="text-center">
                        <div className="text-3xl font-bold text-primary-600">{stats.currentStreak}</div>
                        <div className="text-sm text-gray-600">Current Streak</div>
                      </div>
                      <div className="text-center">
                        <div className="text-3xl font-bold text-green-600">{stats.completionRate}%</div>
                        <div className="text-sm text-gray-600">Completion Rate</div>
                      </div>
                      <div className="text-center">
                        <div className="text-3xl font-bold text-blue-600">{stats.completed}</div>
                        <div className="text-sm text-gray-600">Completed</div>
                      </div>
                      <div className="text-center">
                        <div className="text-3xl font-bold text-gray-600">{stats.total}</div>
                        <div className="text-sm text-gray-600">Total</div>
                      </div>
                    </div>
                  )}
                </div>

                {/* Occurrences */}
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="font-semibold mb-4">Recent Occurrences (Last 30 Days)</h3>
                  <div className="space-y-2">
                    {occurrences.slice(0, 10).map((occurrence) => (
                      <div
                        key={occurrence.id}
                        className="flex items-center justify-between p-3 border rounded hover:bg-gray-50"
                      >
                        <div className="flex items-center gap-3">
                          <input
                            type="checkbox"
                            checked={!!occurrence.completedAt}
                            onChange={() => {
                              if (!occurrence.completedAt) {
                                completeOccurrenceMutation.mutate({
                                  routineId: selectedRoutine.id,
                                  occurrenceId: occurrence.id,
                                });
                              }
                            }}
                            className="h-5 w-5 rounded border-gray-300 text-primary-600"
                          />
                          <div>
                            <div className="font-medium">
                              {new Date(occurrence.scheduledDate).toLocaleDateString('en-US', {
                                weekday: 'short',
                                month: 'short',
                                day: 'numeric',
                              })}
                            </div>
                            {occurrence.completedAt && (
                              <div className="text-xs text-gray-500">
                                Completed {new Date(occurrence.completedAt).toLocaleTimeString()}
                              </div>
                            )}
                            {occurrence.skipped && (
                              <div className="text-xs text-gray-500">Skipped</div>
                            )}
                          </div>
                        </div>
                        {occurrence.completedAt && (
                          <div className="text-green-600">✓</div>
                        )}
                      </div>
                    ))}
                    {occurrences.length === 0 && (
                      <p className="text-sm text-gray-500 text-center py-4">
                        No occurrences in the last 30 days
                      </p>
                    )}
                  </div>
                </div>
              </div>
            ) : (
              <div className="bg-white rounded-lg shadow p-12 text-center">
                <p className="text-gray-500">Select a routine to view details</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
