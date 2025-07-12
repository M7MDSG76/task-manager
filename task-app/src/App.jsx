import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import useAuth from "@/auth/useAuth";
import TasksPage from "@/features/tasks/index.jsx";

export default function App() {
  const { kc, authenticated } = useAuth();

  if (!authenticated) return <p className="p-8 text-center">Authenticating…</p>;

  const logout = () => kc.logout();

  return (
    <BrowserRouter>
      {/* Simple header */}
      <header className="flex justify-between items-center px-4 py-2 bg-gray-900 text-white shadow">
        <h1 className="text-xl font-semibold">Task Manager</h1>
        <div className="flex items-center gap-3">
          <span className="hidden md:inline">{kc.tokenParsed?.preferred_username}</span>
          <Button size="sm" variant="secondary" onClick={logout}>
            Logout
          </Button>
        </div>
      </header>

      {/* App routes */}
      <main className="p-4 max-w-5xl mx-auto">
        <Routes>
          <Route path="/" element={<Navigate to="/tasks" />} />
          <Route path="/tasks" element={<TasksPage />} />
          {/* Fallback */}
          <Route path="*" element={<p>404 – Page not found</p>} />
        </Routes>
      </main>
    </BrowserRouter>
  );
}
