import PropTypes from "prop-types";
import { Button } from "@/components/ui/button";

export default function Pagination({ pageNumber, onPrev, onNext, disableNext }) {
  return (
    <div className="flex justify-between mt-4">
      <Button disabled={pageNumber === 0} onClick={onPrev}>
        Previous
      </Button>
      <span className="self-center">Page {pageNumber + 1}</span>
      <Button disabled={disableNext} onClick={onNext}>
        Next
      </Button>
    </div>
  );
}

Pagination.propTypes = {
  pageNumber: PropTypes.number.isRequired,
  onPrev: PropTypes.func.isRequired,
  onNext: PropTypes.func.isRequired,
  disableNext: PropTypes.bool,
};
