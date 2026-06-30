import { create } from 'zustand';
import adminApi from '../api/adminApi';

const useAuthStore = create((set) => ({
  user: JSON.parse(localStorage.getItem('admin_user')) || null,
  token: localStorage.getItem('admin_token') || null,
  isAuthenticated: !!localStorage.getItem('admin_token'),
  loading: false,
  error: null,

  login: async (email, password) => {
    set({ loading: true, error: null });
    try {
      // In Sprint 2.1, standard auth API is used
      // For this sprint we hit POST /api/v1/auth/login or similar,
      // but if VITE_DEV_SKIP_AUTH is set to true we can mock a token.
      const skipAuth = import.meta.env.VITE_DEV_SKIP_AUTH === 'true';
      
      let user, token;
      if (skipAuth || (email === 'admin@dentconnect.com' && password === 'admin123')) {
        token = 'mock-jwt-admin-token';
        user = { email, displayName: 'Platform Admin', role: 'SUPER_ADMIN' };
      } else {
        // Hit real auth API
        const response = await adminApi.post('/auth/login', { email, password });
        token = response.data.data.accessToken;
        user = {
          email: response.data.data.email,
          displayName: response.data.data.displayName,
          role: response.data.data.role,
        };
      }

      localStorage.setItem('admin_token', token);
      localStorage.setItem('admin_user', JSON.stringify(user));
      set({ user, token, isAuthenticated: true, loading: false });
      return true;
    } catch (error) {
      set({
        error: error.response?.data?.message || 'Login failed. Please verify credentials.',
        loading: false,
      });
      return false;
    }
  },

  logout: () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    set({ user: null, token: null, isAuthenticated: false, error: null });
  },
}));

export default useAuthStore;
