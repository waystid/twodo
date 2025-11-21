import { useAuth } from '../hooks/useAuth';

export function HomePage() {
  const { user, logout } = useAuth();
  const hasCouple = !!user?.coupleId;

  const handleLogout = async () => {
    try {
      await logout();
      window.location.href = '/login';
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  // If user has a couple, redirect to dashboard
  if (hasCouple) {
    window.location.href = '/dashboard';
    return null;
  }

  // Onboarding: No couple yet
  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">TwoDo</h1>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-600">Welcome, {user?.displayName}!</span>
            <button
              onClick={handleLogout}
              className="px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900"
            >
              Logout
            </button>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-5xl font-bold text-gray-900 mb-4">Welcome to TwoDo! 👫</h2>
          <p className="text-xl text-gray-600 mb-12">
            Life management for couples. Let's get you started!
          </p>

          <div className="grid md:grid-cols-2 gap-8 mb-12">
            {/* Create Couple */}
            <div className="bg-white rounded-lg shadow-md p-8 hover:shadow-lg transition">
              <div className="text-4xl mb-4">✨</div>
              <h3 className="text-2xl font-semibold mb-3">Create a Couple</h3>
              <p className="text-gray-600 mb-6">
                Start fresh by creating a new shared space. You'll be able to invite your partner
                after creating it.
              </p>
              <button
                onClick={() => (window.location.href = '/create-couple')}
                className="w-full py-3 px-6 bg-primary-600 text-white rounded-md font-medium hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
              >
                Create Couple
              </button>
            </div>

            {/* Join Couple */}
            <div className="bg-white rounded-lg shadow-md p-8 hover:shadow-lg transition">
              <div className="text-4xl mb-4">🔗</div>
              <h3 className="text-2xl font-semibold mb-3">Join Your Partner</h3>
              <p className="text-gray-600 mb-6">
                Already have an invite code from your partner? Enter it here to join their shared
                space.
              </p>
              <button
                onClick={() => (window.location.href = '/join-couple')}
                className="w-full py-3 px-6 bg-white text-primary-600 border-2 border-primary-600 rounded-md font-medium hover:bg-primary-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
              >
                Join Couple
              </button>
            </div>
          </div>

          <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 text-left max-w-2xl mx-auto">
            <h4 className="font-semibold text-blue-900 mb-2">What is TwoDo?</h4>
            <ul className="text-sm text-blue-800 space-y-2">
              <li>✅ Shared task lists and to-dos</li>
              <li>📅 Shared calendar for important dates</li>
              <li>🔄 Recurring routines and habits</li>
              <li>💬 Quick notes and context on tasks</li>
              <li>🔔 Gentle reminders when things are due</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
