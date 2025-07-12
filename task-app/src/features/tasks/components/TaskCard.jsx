import PropTypes from "prop-types";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useState } from "react";

export default function TaskCard({ task, onDone, onDelete, onUpdate }) {
    const [isEditing, setIsEditing] = useState(false);
    const [editedTask, setEditedTask] = useState(task);

    // Debug logging
    console.log('TaskCard received task:', task);
    console.log('Task ID:', task.id, 'Type:', typeof task.id);
    console.log('Task taskId:', task.taskId, 'Type:', typeof task.taskId);
    
    // Get the actual ID - try both id and taskId
    const taskId = task.id || task.taskId;

    const handleSave = () => {
        // Include taskId in the update data
        const updateData = {
            ...editedTask,
            taskId: taskId
        };
        onUpdate(updateData);
        setIsEditing(false);
    };

    const handleCancel = () => {
        setEditedTask(task);
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <Card className="shadow-md w-full">
                <CardContent className="p-4">
                    <div className="space-y-4">
                        <h3 className="font-semibold text-lg">Edit Task</h3>
                        
                        <div className="space-y-3">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">
                                    Title
                                </label>
                                <input
                                    type="text"
                                    value={editedTask.title}
                                    onChange={(e) => setEditedTask({ ...editedTask, title: e.target.value })}
                                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                    placeholder="Task title"
                                />
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">
                                    Description
                                </label>
                                <textarea
                                    rows="2"
                                    value={editedTask.description}
                                    onChange={(e) => setEditedTask({ ...editedTask, description: e.target.value })}
                                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                                    placeholder="Task description"
                                />
                            </div>
                            
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Priority
                                    </label>
                                    <select
                                        value={editedTask.priority}
                                        onChange={(e) => setEditedTask({ ...editedTask, priority: e.target.value })}
                                        className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                    >
                                        <option value="LOW">LOW</option>
                                        <option value="MEDIUM">MEDIUM</option>
                                        <option value="HIGH">HIGH</option>
                                    </select>
                                </div>
                                
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Status
                                    </label>
                                    <select
                                        value={editedTask.status}
                                        onChange={(e) => setEditedTask({ ...editedTask, status: e.target.value })}
                                        className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                    >
                                        <option value="PENDING">PENDING</option>
                                        <option value="IN_PROGRESS">IN_PROGRESS</option>
                                        <option value="COMPLETED">COMPLETED</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div className="flex gap-2 justify-end pt-2 border-t border-gray-200">
                            <Button size="sm" variant="outline" onClick={handleCancel}>
                                Cancel
                            </Button>
                            <Button size="sm" onClick={handleSave}>
                                Save Changes
                            </Button>
                        </div>
                    </div>
                </CardContent>
            </Card>
        );
    }
    return (
        <Card className="shadow-md w-full">
            <CardContent className="p-4">
                {/* Mobile-first layout */}
                <div className="flex flex-col space-y-4 md:grid md:grid-cols-12 md:gap-4 md:items-start md:space-y-0">
                    {/* Task Info Section */}
                    <div className="md:col-span-6 min-w-0">
                        <p className="font-semibold text-lg break-words" title={task.title}>
                            {task.title}
                        </p>
                        <p className="text-sm text-gray-600 break-words mt-1" title={task.description}>
                            {task.description}
                        </p>
                    </div>
                    
                    {/* Priority and Status */}
                    <div className="md:col-span-3 flex flex-row md:flex-col gap-4 md:gap-1">
                        <div className="flex-1 md:flex-none">
                            <span className="text-xs text-gray-500 uppercase tracking-wide">Priority</span>
                            <p className="text-sm font-medium">{task.priority}</p>
                        </div>
                        <div className="flex-1 md:flex-none">
                            <span className="text-xs text-gray-500 uppercase tracking-wide">Status</span>
                            <p className="text-sm font-medium">{task.status}</p>
                        </div>
                    </div>
                    
                    {/* Actions */}
                    <div className="md:col-span-3 flex flex-wrap gap-2 justify-start md:justify-end">
                        <Button size="sm" variant="outline" onClick={() => setIsEditing(true)}>
                            Edit
                        </Button>
                        {task.status !== "COMPLETED" && (
                            <Button size="sm" onClick={() => onDone({ ...task, status: "COMPLETED", taskId: taskId })}>
                                Mark COMPLETED
                            </Button>
                        )}
                        <Button size="sm" variant="destructive" onClick={() => onDelete(taskId)}>
                            Delete
                        </Button>
                    </div>
                </div>
            </CardContent>
        </Card>
    );
}

TaskCard.propTypes = {
    task: PropTypes.shape({
        id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
        title: PropTypes.string.isRequired,
        description: PropTypes.string.isRequired,
        priority: PropTypes.string.isRequired,
        status: PropTypes.string.isRequired,
    }).isRequired,
    onDone: PropTypes.func.isRequired,
    onDelete: PropTypes.func.isRequired,
    onUpdate: PropTypes.func.isRequired,
};