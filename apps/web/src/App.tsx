import { useEffect, useState } from 'react';
import { useAuth } from './hooks/useAuth';
import { ProtectedRoute } from './components/ProtectedRoute';
import { HomePage } from './pages/HomePage';
import { LoginPage } from './pages/LoginPage';
import { SignupPage } from './pages/SignupPage';
import { VerifyEmailPage } from './pages/VerifyEmailPage';
import { ForgotPasswordPage } from './pages/ForgotPasswordPage';
import { ResetPasswordPage } from './pages/ResetPasswordPage';

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
