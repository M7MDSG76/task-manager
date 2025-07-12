import PropTypes from "prop-types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useState } from "react";

export default function TaskForm({ onSubmit }) {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    priority: "LOW",
    status: "PENDING"
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
    // Reset form after submission
    setFormData({
      title: "",
      description: "",
      priority: "LOW",
      status: "PENDING"
    });
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <form onSubmit={handleSubmit} className="mt-8 bg-white p-4 rounded-xl shadow-lg grid gap-4">
      <h2 className="text-xl font-bold">Create New Task</h2>
      <Input 
        value={formData.title}
        onChange={(e) => handleInputChange('title', e.target.value)}
        placeholder="Title" 
        required 
      />
      <Input 
        value={formData.description}
        onChange={(e) => handleInputChange('description', e.target.value)}
        placeholder="Description" 
        required 
      />
      <Select 
        value={formData.priority} 
        onValueChange={(value) => handleInputChange('priority', value)}
      >
        <SelectTrigger>
          <SelectValue placeholder="Select priority" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="LOW">LOW</SelectItem>
          <SelectItem value="MEDIUM">MEDIUM</SelectItem>
          <SelectItem value="HIGH">HIGH</SelectItem>
        </SelectContent>
      </Select>
      <Select 
        value={formData.status} 
        onValueChange={(value) => handleInputChange('status', value)}
      >
        <SelectTrigger>
          <SelectValue placeholder="Select status" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="PENDING">PENDING</SelectItem>
          <SelectItem value="IN_PROGRESS">IN_PROGRESS</SelectItem>
          <SelectItem value="COMPLETED">COMPLETED</SelectItem>
        </SelectContent>
      </Select>
      <Button type="submit">Add Task</Button>
    </form>
  );
}

TaskForm.propTypes = {
  onSubmit: PropTypes.func.isRequired,
};
