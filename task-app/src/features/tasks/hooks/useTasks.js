import { useState, useEffect, useCallback } from 'react';
import { useTaskApi } from '../../../services/taskApi';

export default function useTasks(initialQuery) {
  const api = useTaskApi();
  const [query, setQuery] = useState(initialQuery);
  const [data, setData] = useState([]);

  const refresh = useCallback(() => {
    api.list(query).then((r) => {
      console.log('API response:', r);
      console.log('API response data:', r.data);
      setData(r.data);
    });
  }, [query]); // Remove 'api' from dependencies

  useEffect(() => {
    refresh();
  }, [query]); // Only depend on query, not refresh

  return {
    tasks: data,
    query,
    setQuery,
    create: (body) => api.create(body).then(refresh),
    update: (body) => api.update(body).then(refresh),
    remove: (id) => {
      console.log('useTasks remove called with ID:', id, 'Type:', typeof id);
      return api.remove(id).then(refresh);
    },
  };
}
