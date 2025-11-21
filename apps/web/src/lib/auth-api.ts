import { apiClient } from './api';
import type {
  RegisterInput,
  LoginInput,
  ResetPasswordRequestInput,
  ResetPasswordInput,
  VerifyEmailInput,
  UserProfile,
} from '@twodo/shared';

export interface AuthResponse {
  accessToken: string;
  user: UserProfile & { coupleId?: string };
}

export interface MessageResponse {
  message: string;
}

export const authApi = {
  async register(data: RegisterInput): Promise<MessageResponse & { user: UserProfile }> {
    return apiClient.post('/auth/register', data);
  },

  async login(data: LoginInput): Promise<AuthResponse> {
    const response = await apiClient.post<AuthResponse>('/auth/login', data);
    // Store the access token
    apiClient.setToken(response.accessToken);
    return response;
  },

  async logout(): Promise<MessageResponse> {
    const response = await apiClient.post<MessageResponse>('/auth/logout');
    // Clear the access token
    apiClient.setToken(null);
    return response;
  },

  async verifyEmail(data: VerifyEmailInput): Promise<MessageResponse & { user: UserProfile }> {
    return apiClient.post('/auth/verify-email', data);
  },

  async refreshToken(): Promise<{ accessToken: string }> {
    const response = await apiClient.post<{ accessToken: string }>('/auth/refresh');
    // Update the access token
    apiClient.setToken(response.accessToken);
    return response;
  },

  async me(): Promise<{ user: UserProfile & { coupleId?: string } }> {
    return apiClient.get('/auth/me');
  },

  async forgotPassword(data: ResetPasswordRequestInput): Promise<MessageResponse> {
    return apiClient.post('/auth/forgot-password', data);
  },

  async resetPassword(data: ResetPasswordInput): Promise<MessageResponse> {
    return apiClient.post('/auth/reset-password', data);
  },

  async resendVerification(email: string): Promise<MessageResponse> {
    return apiClient.post('/auth/resend-verification', { email });
  },
};
