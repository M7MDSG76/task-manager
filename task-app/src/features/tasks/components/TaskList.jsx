import PropTypes from "prop-types";
import TaskCard from "@/features/tasks/components/TaskCard.jsx";

export default function TaskList({ tasks, onDone, onDelete, onUpdate }) {
  if (!tasks.length) return <p className="text-center text-gray-500">No tasks found.</p>;

  return (
    <div className="grid gap-4">
      {tasks.map((task) => (
        <TaskCard key={task.id} task={task} onDone={onDone} onDelete={onDelete} onUpdate={onUpdate} />
      ))}
    </div>
  );
}

TaskList.propTypes = {
  tasks: PropTypes.arrayOf(PropTypes.object).isRequired,
  onDone: PropTypes.func.isRequired,
  onDelete: PropTypes.func.isRequired,
  onUpdate: PropTypes.func.isRequired,
};
