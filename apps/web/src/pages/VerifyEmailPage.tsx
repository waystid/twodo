import { useEffect, useState } from 'react';
import { authApi } from '../lib/auth-api';

export function VerifyEmailPage() {
  const [status, setStatus] = useState<'verifying' | 'success' | 'error'>('verifying');
  const [message, setMessage] = useState<string>('');

  useEffect(() => {
    const verifyEmail = async () => {
      const params = new URLSearchParams(window.location.search);
      const token = params.get('token');

      if (!token) {
        setStatus('error');
        setMessage('Invalid verification link');
        return;
      }

      try {
        const response = await authApi.verifyEmail({ token });
        setStatus('success');
        setMessage(response.message);
      } catch (error: any) {
        setStatus('error');
        setMessage(error.message || 'Failed to verify email');
      }
    };

    verifyEmail();
  }, []);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          {status === 'verifying' && (
            <>
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-primary-100">
                <div className="animate-spin h-6 w-6 border-2 border-primary-600 border-t-transparent rounded-full"></div>
              </div>
              <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
                Verifying your email...
              </h2>
            </>
          )}

          {status === 'success' && (
            <>
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100">
                <svg
                  className="h-6 w-6 text-green-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </div>
              <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
                Email verified!
              </h2>
              <p className="mt-2 text-sm text-gray-600">{message}</p>
              <div className="mt-6">
                <a
                  href="/login"
                  className="font-medium text-primary-600 hover:text-primary-500"
                >
                  Continue to login
                </a>
              </div>
            </>
          )}

          {status === 'error' && (
            <>
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100">
                <svg
                  className="h-6 w-6 text-red-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </div>
              <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
                Verification failed
              </h2>
              <p className="mt-2 text-sm text-gray-600">{message}</p>
              <div className="mt-6">
                <a
                  href="/login"
                  className="font-medium text-primary-600 hover:text-primary-500"
                >
                  Back to login
                </a>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
