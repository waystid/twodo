import { apiClient } from './api';
import type { CreateCoupleInput, JoinCoupleInput, UpdateCoupleInput, CoupleWithMembers } from '@twodo/shared';

export interface CoupleResponse {
  couple: CoupleWithMembers;
}

export interface InviteCodeResponse {
  message: string;
  inviteCode: string;
  expiresAt: Date;
}

export const coupleApi = {
  async createCouple(data: CreateCoupleInput): Promise<CoupleResponse> {
    return apiClient.post('/couples', data);
  },

  async getMyCouple(): Promise<CoupleResponse> {
    return apiClient.get('/couples/me');
  },

  async getCouple(coupleId: string): Promise<CoupleResponse> {
    return apiClient.get(`/couples/${coupleId}`);
  },

  async updateCouple(coupleId: string, data: UpdateCoupleInput): Promise<CoupleResponse> {
    return apiClient.put(`/couples/${coupleId}`, data);
  },

  async generateInviteCode(coupleId: string): Promise<InviteCodeResponse> {
    return apiClient.post(`/couples/${coupleId}/invite`);
  },

  async joinCouple(data: JoinCoupleInput): Promise<CoupleResponse> {
    return apiClient.post('/couples/join', data);
  },

  async leaveCouple(coupleId: string): Promise<{ message: string }> {
    return apiClient.post(`/couples/${coupleId}/leave`);
  },
};
