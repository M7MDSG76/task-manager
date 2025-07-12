import PropTypes from "prop-types";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

export default function TaskFilters({ query, onChange }) {
  const update = (patch) => onChange({ ...query, ...patch, pageNumber: 0 });

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
      <Select value={query.priority || "ALL"} onValueChange={(v) => update({ priority: v === "ALL" ? undefined : v })}>
        <SelectTrigger>
          <SelectValue placeholder="Select priority" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="ALL">All Priorities</SelectItem>
          <SelectItem value="LOW">LOW</SelectItem>
          <SelectItem value="MEDIUM">MEDIUM</SelectItem>
          <SelectItem value="HIGH">HIGH</SelectItem>
        </SelectContent>
      </Select>

      <Select value={query.status || "ALL"} onValueChange={(v) => update({ status: v === "ALL" ? undefined : v })}>
        <SelectTrigger>
          <SelectValue placeholder="Select status" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="ALL">All Statuses</SelectItem>
          <SelectItem value="PENDING">PENDING</SelectItem>
          <SelectItem value="IN_PROGRESS">IN_PROGRESS</SelectItem>
          <SelectItem value="COMPLETED">COMPLETED</SelectItem>
        </SelectContent>
      </Select>

      <Input
        placeholder="Search title or description…"
        value={query.search || ""}
        onChange={(e) => update({ search: e.target.value })}
      />

      <Select value={String(query.pageSize)} onValueChange={(v) => update({ pageSize: Number(v) })}>
        <SelectTrigger>
          <SelectValue placeholder="Page size" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="3">3 / page</SelectItem>
          <SelectItem value="5">5 / page</SelectItem>
          <SelectItem value="10">10 / page</SelectItem>
        </SelectContent>
      </Select>
    </div>
  );
}

TaskFilters.propTypes = {
  query: PropTypes.object.isRequired,
  onChange: PropTypes.func.isRequired,
};
