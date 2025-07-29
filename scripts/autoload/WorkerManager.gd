extends Node

# Worker management system autoload for worker hiring and assignment
# Uses intentional naming conventions for future maintainability

const WorkerDefinition = preload("res://scripts/resources/WorkerDefinition.gd")

# Constants for worker mechanics (extracted per code review feedback)
const WORKER_QUOTA_PER_SECOND: float = 1.0
const KITCHEN_PRODUCTION_RATE: float = 0.5
const OFFICE_EFFICIENCY_BONUS_PER_WORKER: float = 0.1  # 10% bonus per office worker

# Signals
signal worker_hired(worker_id: String, cost: int)
signal worker_assigned(worker_id: String, assignment: WorkerDefinition.WorkerAssignment)
signal worker_quota_warning(worker_id: String, quota_deficit: float)
signal production_rates_changed

# Worker tracking
var hired_workers: Array[Dictionary] = []  # Array of worker data dictionaries
var next_worker_id: int = 1
var max_workers: int = 2  # Initial worker limit (can be upgraded)

# Production tracking
var kitchen_production_timer: Timer
var office_efficiency_bonus: float = 1.0

# References to other managers
var hot_dog_manager: Node
var building_manager: Node

const DEBUG_MODE: bool = false


func _ready():
	print("WorkerManager: Initialized")

	# Get references to other managers
	hot_dog_manager = get_node_or_null("/root/HotDogManager")
	building_manager = get_node_or_null("/root/BuildingManager")

	# Setup production timer for kitchen workers
	_setup_production_timer()

	# Connect to save system
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)


func _setup_production_timer():
	"""Setup timer for kitchen worker production"""
	kitchen_production_timer = Timer.new()
	kitchen_production_timer.wait_time = 1.0  # Process every second
	kitchen_production_timer.timeout.connect(_process_worker_production)
	add_child(kitchen_production_timer)
	kitchen_production_timer.start()


func can_hire_worker() -> bool:
	"""Check if a new worker can be hired"""
	# Check if office is purchased
	if not building_manager or not building_manager.is_building_purchased("office"):
		return false

	# Check worker limit
	if hired_workers.size() >= max_workers:
		return false

	# Check affordability
	var hire_cost = get_next_hire_cost()
	if not hot_dog_manager or not hot_dog_manager.can_afford(hire_cost):
		return false

	return true


func get_next_hire_cost() -> int:
	"""Get the cost to hire the next worker (10, 100, 1000)"""
	var worker_count = hired_workers.size()
	match worker_count:
		0:
			return 10
		1:
			return 100
		2:
			return 1000
		_:
			return 1000 + (worker_count - 2) * 500  # Scaling cost for additional workers


func hire_worker(
	assignment: WorkerDefinition.WorkerAssignment = WorkerDefinition.WorkerAssignment.KITCHEN
) -> bool:
	"""Hire a new worker with the specified assignment"""
	if not can_hire_worker():
		return false

	var hire_cost = get_next_hire_cost()

	# Deduct currency
	if not hot_dog_manager.spend_currency(hire_cost, "worker_hire"):
		return false

	# Create worker data
	var worker_data = {
		"worker_id": "worker_%d" % next_worker_id,
		"display_name": "Worker %d" % next_worker_id,
		"assignment": assignment,
		"hire_cost": hire_cost,
		"hot_dogs_consumed": 0.0,
		"hot_dogs_produced": 0.0,
		"production_buffer": 0.0,
		"hire_time": Time.get_datetime_string_from_system()
	}

	hired_workers.append(worker_data)
	next_worker_id += 1

	# Update production calculations
	_recalculate_production_rates()

	# Emit signals
	emit_signal("worker_hired", worker_data["worker_id"], hire_cost)

	# Add event to event log
	var event_log_manager = get_node_or_null("/root/EventLogManager")
	if event_log_manager:
		event_log_manager.add_worker_event(
			"Worker Hired", "Hired %s for %d currency" % [worker_data["display_name"], hire_cost]
		)

	print("WorkerManager: Hired %s for %d currency" % [worker_data["display_name"], hire_cost])
	return true


func assign_worker(worker_id: String, assignment: WorkerDefinition.WorkerAssignment) -> bool:
	"""Assign a worker to a different station"""
	var worker = get_worker_by_id(worker_id)
	if not worker:
		return false

	worker["assignment"] = assignment
	_recalculate_production_rates()

	emit_signal("worker_assigned", worker_id, assignment)

	var assignment_name = (
		"Kitchen" if assignment == WorkerDefinition.WorkerAssignment.KITCHEN else "Office"
	)
	print("WorkerManager: Assigned %s to %s" % [worker["display_name"], assignment_name])
	return true


func _process_worker_production():
	"""Process worker production and consumption every second"""
	if hired_workers.is_empty():
		return

	var kitchen_workers = get_workers_by_assignment(WorkerDefinition.WorkerAssignment.KITCHEN)
	var office_workers = get_workers_by_assignment(WorkerDefinition.WorkerAssignment.OFFICE)

	# Update office efficiency bonus
	office_efficiency_bonus = 1.0 + (office_workers.size() * OFFICE_EFFICIENCY_BONUS_PER_WORKER)

	# Process kitchen workers
	for worker in kitchen_workers:
		_process_kitchen_worker(worker)

	# Update office workers consumption
	for worker in office_workers:
		_process_office_worker(worker)


func _process_kitchen_worker(worker: Dictionary):
	"""Process a kitchen worker's production and consumption"""
	var quota_per_second = WORKER_QUOTA_PER_SECOND
	var production_per_second = KITCHEN_PRODUCTION_RATE * office_efficiency_bonus

	# Initialize production buffer if not already present
	if not worker.has("production_buffer"):
		worker["production_buffer"] = 0.0

	# Check if we have enough hot dogs for quota
	if hot_dog_manager and hot_dog_manager.hot_dogs_inventory >= int(quota_per_second):
		# Consume hot dogs
		var quota_to_consume = int(quota_per_second)
		hot_dog_manager.hot_dogs_inventory -= quota_to_consume
		worker["hot_dogs_consumed"] += quota_to_consume

		# Accumulate production in the buffer
		worker["production_buffer"] += production_per_second

		# Produce whole hot dogs from the buffer
		var whole_hot_dogs = int(worker["production_buffer"])
		if whole_hot_dogs > 0:
			hot_dog_manager.produce_hot_dogs(whole_hot_dogs, "kitchen_worker")
			worker["hot_dogs_produced"] += whole_hot_dogs
			worker["production_buffer"] -= whole_hot_dogs
	else:
		# Not enough hot dogs for quota - emit warning
		var deficit = (
			quota_per_second - (hot_dog_manager.hot_dogs_inventory if hot_dog_manager else 0)
		)
		emit_signal("worker_quota_warning", worker["worker_id"], deficit)


func _process_office_worker(worker: Dictionary):
	"""Process an office worker's consumption (no production)"""
	var quota_per_second = WORKER_QUOTA_PER_SECOND

	# Check if we have enough hot dogs for quota
	if hot_dog_manager and hot_dog_manager.hot_dogs_inventory >= int(quota_per_second):
		var quota_to_consume = int(quota_per_second)
		hot_dog_manager.hot_dogs_inventory -= quota_to_consume
		worker["hot_dogs_consumed"] += quota_to_consume
	else:
		# Not enough hot dogs for quota - emit warning
		var deficit = (
			quota_per_second - (hot_dog_manager.hot_dogs_inventory if hot_dog_manager else 0)
		)
		emit_signal("worker_quota_warning", worker["worker_id"], deficit)


func _recalculate_production_rates():
	"""Recalculate and emit production rate changes"""
	emit_signal("production_rates_changed")


func _emit_production_rates_changed():
	"""Emit production rates changed signal for UI updates"""
	emit_signal("production_rates_changed")


func get_workers_by_assignment(assignment: WorkerDefinition.WorkerAssignment) -> Array[Dictionary]:
	"""Get all workers assigned to a specific station"""
	var workers: Array[Dictionary] = []
	for worker in hired_workers:
		if worker["assignment"] == assignment:
			workers.append(worker)
	return workers


func get_worker_count() -> int:
	"""Get the total number of hired workers"""
	return hired_workers.size()


func get_kitchen_production_rate() -> float:
	"""Get the total hot dog production rate from kitchen workers"""
	var kitchen_workers = get_workers_by_assignment(WorkerDefinition.WorkerAssignment.KITCHEN)
	return kitchen_workers.size() * KITCHEN_PRODUCTION_RATE * office_efficiency_bonus


func get_total_consumption_rate() -> float:
	"""Get the total hot dog consumption rate from all workers"""
	return hired_workers.size() * WORKER_QUOTA_PER_SECOND  # 1 hot dog per second per worker


func get_worker_by_id(worker_id: String) -> Dictionary:
	"""Get worker data by ID"""
	for worker in hired_workers:
		if worker["worker_id"] == worker_id:
			return worker
	return {}


func _on_save_data_loaded(save_data: Dictionary):
	"""Load worker data from save file"""
	if save_data.has("workers"):
		var workers_data = save_data["workers"]
		var loaded_workers = workers_data.get("hired_workers", [])
		# Ensure type safety when loading from save data
		hired_workers.clear()
		for worker in loaded_workers:
			hired_workers.append(worker as Dictionary)
		next_worker_id = workers_data.get("next_worker_id", 1)
		max_workers = workers_data.get("max_workers", 2)

		# Ensure backward compatibility - add production buffer to existing workers
		for worker in hired_workers:
			if not worker.has("production_buffer"):
				worker["production_buffer"] = 0.0

		_recalculate_production_rates()
		print("WorkerManager: Loaded %d workers from save" % hired_workers.size())


func get_save_data() -> Dictionary:
	"""Get worker data for saving"""
	return {
		"workers":
		{
			"hired_workers": hired_workers,
			"next_worker_id": next_worker_id,
			"max_workers": max_workers
		}
	}


func reset_workers():
	"""Reset all workers to starting state (for new game)"""
	hired_workers.clear()
	next_worker_id = 1
	max_workers = 2
	office_efficiency_bonus = 1.0
	print("WorkerManager: Reset to starting values")
