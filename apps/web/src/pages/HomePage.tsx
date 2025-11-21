import { useAuth } from '../hooks/useAuth';

export function HomePage() {
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    try {
      await logout();
      window.location.href = '/login';
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">TwoDo</h1>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-600">
              Welcome, {user?.displayName}!
            </span>
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
        <div className="text-center">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Welcome to TwoDo! 👫
          </h2>
          <p className="text-xl text-gray-600 mb-8">
            Your shared life management app for couples
          </p>

          <div className="bg-white rounded-lg shadow-md p-8 max-w-2xl mx-auto">
            <h3 className="text-2xl font-semibold mb-4">What's next?</h3>
            <div className="text-left space-y-4">
              <div className="flex items-start">
                <span className="text-2xl mr-4">1️⃣</span>
                <div>
                  <h4 className="font-semibold text-lg">Create or join a couple</h4>
                  <p className="text-gray-600">
                    Start by creating a couple space or join your partner's space
                  </p>
                </div>
              </div>
              <div className="flex items-start">
                <span className="text-2xl mr-4">2️⃣</span>
                <div>
                  <h4 className="font-semibold text-lg">Add your first tasks</h4>
                  <p className="text-gray-600">
                    Create shared task lists for groceries, projects, and more
                  </p>
                </div>
              </div>
              <div className="flex items-start">
                <span className="text-2xl mr-4">3️⃣</span>
                <div>
                  <h4 className="font-semibold text-lg">Set up routines</h4>
                  <p className="text-gray-600">
                    Define recurring routines to stay on track together
                  </p>
                </div>
              </div>
            </div>

            <div className="mt-8 p-4 bg-yellow-50 border border-yellow-200 rounded-md">
              <p className="text-sm text-yellow-800">
                <strong>🚧 Development in Progress</strong><br />
                Features are being actively developed. Check back soon!
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
