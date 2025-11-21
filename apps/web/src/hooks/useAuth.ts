import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { authApi } from '../lib/auth-api';
import { useAuthStore } from '../stores/auth';
import type { LoginInput, RegisterInput } from '@twodo/shared';

export function useAuth() {
  const queryClient = useQueryClient();
  const { user, isAuthenticated, setUser, logout: clearAuth } = useAuthStore();

  // Get current user
  const { data, isLoading, error } = useQuery({
    queryKey: ['auth', 'me'],
    queryFn: () => authApi.me(),
    enabled: isAuthenticated,
    retry: false,
  });

  // Login mutation
  const loginMutation = useMutation({
    mutationFn: (credentials: LoginInput) => authApi.login(credentials),
    onSuccess: (data) => {
      setUser(data.user);
      queryClient.setQueryData(['auth', 'me'], { user: data.user });
    },
  });

  // Register mutation
  const registerMutation = useMutation({
    mutationFn: (data: RegisterInput) => authApi.register(data),
  });

  // Logout mutation
  const logoutMutation = useMutation({
    mutationFn: () => authApi.logout(),
    onSuccess: () => {
      clearAuth();
      queryClient.clear();
    },
  });

  return {
    user: data?.user || user,
    isAuthenticated,
    isLoading,
    error,
    login: loginMutation.mutateAsync,
    register: registerMutation.mutateAsync,
    logout: logoutMutation.mutateAsync,
    isLoggingIn: loginMutation.isPending,
    isRegistering: registerMutation.isPending,
  };
}
