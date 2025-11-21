import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { eventApi } from '../lib/event-api';
import type { Event } from '@twodo/shared';

export function CalendarPage() {
  const queryClient = useQueryClient();
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [showEventForm, setShowEventForm] = useState(false);
  const [eventTitle, setEventTitle] = useState('');
  const [eventDescription, setEventDescription] = useState('');
  const [eventTime, setEventTime] = useState('09:00');
  const [isAllDay, setIsAllDay] = useState(false);

  // Calculate month boundaries
  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);

  // Fetch events for current month
  const { data: eventsData } = useQuery({
    queryKey: ['events', year, month],
    queryFn: () =>
      eventApi.getEvents({
        start: firstDay.toISOString(),
        end: lastDay.toISOString(),
      }),
  });

  // Create event mutation
  const createEventMutation = useMutation({
    mutationFn: (data: any) => eventApi.createEvent(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['events'] });
      setEventTitle('');
      setEventDescription('');
      setShowEventForm(false);
      setSelectedDate(null);
    },
  });

  const events = eventsData?.events || [];

  // Generate calendar days
  const startDay = firstDay.getDay(); // 0 = Sunday
  const daysInMonth = lastDay.getDate();
  const calendarDays: (Date | null)[] = [];

  // Add empty cells for days before the first day
  for (let i = 0; i < startDay; i++) {
    calendarDays.push(null);
  }

  // Add days of the month
  for (let day = 1; day <= daysInMonth; day++) {
    calendarDays.push(new Date(year, month, day));
  }

  // Get events for a specific date
  const getEventsForDate = (date: Date) => {
    return events.filter((event: Event) => {
      const eventDate = new Date(event.startDate);
      return (
        eventDate.getDate() === date.getDate() &&
        eventDate.getMonth() === date.getMonth() &&
        eventDate.getFullYear() === date.getFullYear()
      );
    });
  };

  const handleCreateEvent = () => {
    if (!selectedDate || !eventTitle) return;

    const startDate = new Date(selectedDate);
    if (!isAllDay) {
      const [hours, minutes] = eventTime.split(':');
      startDate.setHours(parseInt(hours), parseInt(minutes));
    }

    createEventMutation.mutate({
      title: eventTitle,
      description: eventDescription || undefined,
      startDate: startDate.toISOString(),
      isAllDay,
    });
  };

  const goToPreviousMonth = () => {
    setCurrentDate(new Date(year, month - 1));
  };

  const goToNextMonth = () => {
    setCurrentDate(new Date(year, month + 1));
  };

  const goToToday = () => {
    setCurrentDate(new Date());
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b p-6">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-2xl font-bold text-gray-900">Calendar</h1>
          <button
            onClick={() => (window.location.href = '/dashboard')}
            className="text-sm text-gray-600 hover:text-gray-900"
          >
            ← Back to Dashboard
          </button>
        </div>

        {/* Month navigation */}
        <div className="flex items-center justify-between">
          <button
            onClick={goToPreviousMonth}
            className="px-4 py-2 border rounded hover:bg-gray-50"
          >
            ← Previous
          </button>

          <div className="flex items-center gap-4">
            <h2 className="text-xl font-semibold">
              {currentDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
            </h2>
            <button onClick={goToToday} className="text-sm text-primary-600 hover:text-primary-700">
              Today
            </button>
          </div>

          <button onClick={goToNextMonth} className="px-4 py-2 border rounded hover:bg-gray-50">
            Next →
          </button>
        </div>
      </div>

      {/* Calendar Grid */}
      <div className="p-6">
        <div className="bg-white rounded-lg shadow">
          {/* Day headers */}
          <div className="grid grid-cols-7 border-b">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
              <div key={day} className="p-3 text-center text-sm font-semibold text-gray-600">
                {day}
              </div>
            ))}
          </div>

          {/* Calendar days */}
          <div className="grid grid-cols-7">
            {calendarDays.map((date, index) => {
              if (!date) {
                return <div key={`empty-${index}`} className="min-h-24 border-r border-b" />;
              }

              const dayEvents = getEventsForDate(date);
              const isToday =
                date.getDate() === new Date().getDate() &&
                date.getMonth() === new Date().getMonth() &&
                date.getFullYear() === new Date().getFullYear();

              return (
                <div
                  key={date.toISOString()}
                  className="min-h-24 border-r border-b p-2 hover:bg-gray-50 cursor-pointer"
                  onClick={() => {
                    setSelectedDate(date);
                    setShowEventForm(true);
                  }}
                >
                  <div
                    className={`text-sm font-medium mb-1 ${
                      isToday
                        ? 'bg-primary-600 text-white rounded-full w-6 h-6 flex items-center justify-center'
                        : 'text-gray-900'
                    }`}
                  >
                    {date.getDate()}
                  </div>
                  <div className="space-y-1">
                    {dayEvents.map((event: Event) => (
                      <div
                        key={event.id}
                        className="text-xs bg-primary-100 text-primary-800 rounded px-2 py-1 truncate"
                      >
                        {event.title}
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Event creation modal */}
      {showEventForm && selectedDate && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
            <h3 className="text-xl font-bold mb-4">
              Create Event - {selectedDate.toLocaleDateString()}
            </h3>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <input
                  type="text"
                  className="w-full px-3 py-2 border rounded"
                  value={eventTitle}
                  onChange={(e) => setEventTitle(e.target.value)}
                  placeholder="Event title"
                  autoFocus
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Description (optional)
                </label>
                <textarea
                  className="w-full px-3 py-2 border rounded"
                  value={eventDescription}
                  onChange={(e) => setEventDescription(e.target.value)}
                  placeholder="Event description"
                  rows={3}
                />
              </div>

              <div>
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={isAllDay}
                    onChange={(e) => setIsAllDay(e.target.checked)}
                    className="rounded"
                  />
                  <span className="text-sm font-medium text-gray-700">All day event</span>
                </label>
              </div>

              {!isAllDay && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Time</label>
                  <input
                    type="time"
                    className="w-full px-3 py-2 border rounded"
                    value={eventTime}
                    onChange={(e) => setEventTime(e.target.value)}
                  />
                </div>
              )}
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={handleCreateEvent}
                disabled={!eventTitle}
                className="flex-1 py-2 px-4 bg-primary-600 text-white rounded hover:bg-primary-700 disabled:opacity-50"
              >
                Create Event
              </button>
              <button
                onClick={() => {
                  setShowEventForm(false);
                  setSelectedDate(null);
                  setEventTitle('');
                  setEventDescription('');
                }}
                className="py-2 px-4 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
