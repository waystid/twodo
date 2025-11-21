import { useEffect, useState } from 'react';
import { useAuth } from './hooks/useAuth';
import { ProtectedRoute } from './components/ProtectedRoute';
import { HomePage } from './pages/HomePage';
import { LoginPage } from './pages/LoginPage';
import { SignupPage } from './pages/SignupPage';
import { VerifyEmailPage } from './pages/VerifyEmailPage';
import { ForgotPasswordPage } from './pages/ForgotPasswordPage';
import { ResetPasswordPage } from './pages/ResetPasswordPage';
import { CreateCouplePage } from './pages/CreateCouplePage';
import { JoinCouplePage } from './pages/JoinCouplePage';
import { DashboardPage } from './pages/DashboardPage';
import { RoutinesPage } from './pages/RoutinesPage';

function Router() {
  const [currentPath, setCurrentPath] = useState(window.location.pathname);
  const { isAuthenticated } = useAuth();

  useEffect(() => {
    const onLocationChange = () => {
      setCurrentPath(window.location.pathname);
    };

    window.addEventListener('popstate', onLocationChange);
    return () => window.removeEventListener('popstate', onLocationChange);
  }, []);

  // Redirect authenticated users away from auth pages
  useEffect(() => {
    const authPages = ['/login', '/signup', '/forgot-password', '/reset-password'];
    if (isAuthenticated && authPages.includes(currentPath)) {
      window.location.href = '/';
    }
  }, [isAuthenticated, currentPath]);

  // Route mapping
  const routes: Record<string, JSX.Element> = {
    '/': (
      <ProtectedRoute>
        <HomePage />
      </ProtectedRoute>
    ),
    '/dashboard': (
      <ProtectedRoute>
        <DashboardPage />
      </ProtectedRoute>
    ),
    '/routines': (
      <ProtectedRoute>
        <RoutinesPage />
      </ProtectedRoute>
    ),
    '/create-couple': (
      <ProtectedRoute>
        <CreateCouplePage />
      </ProtectedRoute>
    ),
    '/join-couple': (
      <ProtectedRoute>
        <JoinCouplePage />
      </ProtectedRoute>
    ),
    '/login': <LoginPage />,
    '/signup': <SignupPage />,
    '/verify-email': <VerifyEmailPage />,
    '/forgot-password': <ForgotPasswordPage />,
    '/reset-password': <ResetPasswordPage />,
  };

  return routes[currentPath] || routes['/'];
}

function App() {
  return <Router />;
}

export default App;
