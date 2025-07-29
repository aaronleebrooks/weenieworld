class_name WorkerDefinition
extends Resource

# Worker definition resource for configurable workers
# Uses intentional naming conventions for future maintainability

@export var worker_id: String
@export var display_name: String
@export var assignment: WorkerAssignment = WorkerAssignment.KITCHEN
@export var hire_cost: int = 10
@export var hot_dog_quota_per_second: float = 1.0
@export var production_rate_per_second: float = 0.5  # For kitchen workers
@export var efficiency_bonus: float = 1.0  # For office workers

enum WorkerAssignment {
	KITCHEN,  # Auto - produce hot dogs
	OFFICE    # Improve all worker efficiency
}