import TaskList from '@/features/tasks/components/TaskList.jsx';
import TaskFilters from '@/features/tasks/components/TaskFilters.jsx';
import TaskForm from '@/features/tasks/components/TaskForm.jsx';
import useTasks from '@/features/tasks/hooks/useTasks.js';

export default function TasksPage() {
  const {
    tasks,
    query,
    setQuery,
    create,
    update,
    remove,
  } = useTasks({ pageSize: 3, pageNumber: 0 });
console.log(`TasksPage rendered with query:`, query);
  return (
    <div className="p-4">
      <TaskFilters query={query} onChange={setQuery} />
      <TaskList tasks={tasks} onDone={update} onDelete={remove} onUpdate={update} />
      <TaskForm onSubmit={create} />
    </div>
  );
}
