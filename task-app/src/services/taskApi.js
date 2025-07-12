import axios from 'axios';
import { useMemo } from 'react';
import useAuth from '@/auth/useAuth';

const instance = axios.create({
  baseURL: 'http://localhost:8084/task-management/api/v1/tasks',
});

export const useTaskApi = () => {
  const { kc } = useAuth();

  // Set up interceptor once
  useMemo(() => {
    instance.interceptors.request.clear(); 
    instance.interceptors.request.use((cfg) => {
      if (kc?.token) {
        cfg.headers.Authorization = `Bearer ${kc.token}`;
      }
      return cfg;
    });
  }, [kc?.token]);
  console.log('Task API initialized with base URL:', instance.defaults.baseURL);

  // Memoize the API object to prevent recreation on every render
  return useMemo(() => ({
    list: (params) => {
      // Use search endpoint if search parameter is provided
      if (params?.search) {
        return instance.get('/search', { params });
      }
      // Use regular tasks endpoint for filtering
      return instance.get('', { params });
    },
    create: (data) => instance.post('', null, { params: data }),
    update: (data) => instance.put('', null, { params: data }),
    remove: (taskId) => {
      console.log(`Removing task with ID:`, taskId);
      return instance.delete('', { params: { taskId } });
    },
  }), []);
};
