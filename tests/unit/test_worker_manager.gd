extends GdUnitTestSuite

# Test suite for WorkerManager autoload
# Tests worker hiring, assignment, production, and consumption functionality

const WorkerDefinition = preload("res://scripts/resources/WorkerDefinition.gd")

var worker_manager: Node
var hot_dog_manager: Node
var building_manager: Node


func before():
	# Setup before each test
	worker_manager = get_node_or_null("/root/WorkerManager")
	if not worker_manager:
		# If autoload not available, create a mock instance for testing
		worker_manager = preload("res://scripts/autoload/WorkerManager.gd").new()
		add_child(worker_manager)

	hot_dog_manager = get_node_or_null("/root/HotDogManager")
	if not hot_dog_manager:
		# Create mock HotDogManager for testing
		hot_dog_manager = preload("res://scripts/autoload/HotDogManager.gd").new()
		add_child(hot_dog_manager)
		worker_manager.hot_dog_manager = hot_dog_manager

	building_manager = get_node_or_null("/root/BuildingManager")
	if not building_manager:
		# Create mock BuildingManager for testing
		building_manager = preload("res://scripts/autoload/BuildingManager.gd").new()
		add_child(building_manager)
		worker_manager.building_manager = building_manager

	# Reset state for clean tests
	worker_manager.reset_workers()
	hot_dog_manager.currency_balance = 0
	hot_dog_manager.hot_dogs_inventory = 0
	building_manager.reset_buildings()


func test_initial_state():
	# Test WorkerManager starts with no hired workers
	assert_int(worker_manager.get_worker_count()).is_equal(0)
	assert_array(worker_manager.hired_workers).is_empty()
	assert_int(worker_manager.max_workers).is_equal(2)


func test_hire_cost_scaling():
	# Test worker hire cost scaling (10, 100, 1000)
	assert_int(worker_manager.get_next_hire_cost()).is_equal(10)

	# Simulate hiring workers to test cost scaling with complete worker structures
	worker_manager.hired_workers.append(
		{
			"worker_id": "test1",
			"display_name": "Test Worker 1",
			"assignment": WorkerDefinition.WorkerAssignment.KITCHEN,
			"hire_cost": 10,
			"hot_dogs_consumed": 0.0,
			"hot_dogs_produced": 0.0,
			"production_buffer": 0.0,
			"hire_time": "test_time"
		}
	)
	assert_int(worker_manager.get_next_hire_cost()).is_equal(100)

	worker_manager.hired_workers.append(
		{
			"worker_id": "test2",
			"display_name": "Test Worker 2",
			"assignment": WorkerDefinition.WorkerAssignment.OFFICE,
			"hire_cost": 100,
			"hot_dogs_consumed": 0.0,
			"hot_dogs_produced": 0.0,
			"production_buffer": 0.0,
			"hire_time": "test_time"
		}
	)
	assert_int(worker_manager.get_next_hire_cost()).is_equal(1000)


func test_cannot_hire_without_office():
	# Test that workers cannot be hired without office building
	hot_dog_manager.currency_balance = 1000

	# Office not purchased
	assert_bool(worker_manager.can_hire_worker()).is_false()

	# Purchase office
	building_manager.purchased_buildings["office"] = true
	assert_bool(worker_manager.can_hire_worker()).is_true()


func test_cannot_hire_without_currency():
	# Test that workers cannot be hired without sufficient currency
	# Setup office purchased
	building_manager.purchased_buildings["office"] = true

	# Not enough currency
	hot_dog_manager.currency_balance = 5
	assert_bool(worker_manager.can_hire_worker()).is_false()

	# Enough currency
	hot_dog_manager.currency_balance = 10
	assert_bool(worker_manager.can_hire_worker()).is_true()


func test_worker_limit():
	# Test worker hiring respects max worker limit
	# Setup conditions
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 10000

	# Should be able to hire up to limit
	assert_bool(worker_manager.can_hire_worker()).is_true()

	# Simulate hiring to the limit with complete worker structures
	for i in range(worker_manager.max_workers):
		worker_manager.hired_workers.append(
			{
				"worker_id": "test_%d" % i,
				"display_name": "Test Worker %d" % i,
				"assignment": WorkerDefinition.WorkerAssignment.KITCHEN,
				"hire_cost": 10,
				"hot_dogs_consumed": 0.0,
				"hot_dogs_produced": 0.0,
				"production_buffer": 0.0,
				"hire_time": "test_time"
			}
		)

	# Should not be able to hire more
	assert_bool(worker_manager.can_hire_worker()).is_false()


func test_successful_hire():
	# Test successful worker hiring
	# Setup conditions
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 100

	# Monitor signals using GdUnit4 approach
	var signal_monitor = monitor_signal(worker_manager, "worker_hired")

	# Hire worker
	var result = worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	assert_bool(result).is_true()

	# Verify state changes
	assert_int(worker_manager.get_worker_count()).is_equal(1)
	assert_int(hot_dog_manager.currency_balance).is_equal(90)  # 100 - 10

	# Allow one frame for signal processing
	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted()

	# Check worker data
	var worker = worker_manager.hired_workers[0]
	assert_str(worker["worker_id"]).is_equal("worker_1")
	assert_str(worker["display_name"]).is_equal("Worker 1")
	assert_int(worker["assignment"]).is_equal(WorkerDefinition.WorkerAssignment.KITCHEN)
	assert_float(worker["production_buffer"]).is_equal(0.0)


func test_worker_assignment():
	# Test worker assignment changes
	# Setup and hire worker
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 100
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)

	var worker_id = worker_manager.hired_workers[0]["worker_id"]

	# Monitor signals using GdUnit4 approach
	var signal_monitor = monitor_signal(worker_manager, "worker_assigned")

	# Change assignment
	var result = worker_manager.assign_worker(worker_id, WorkerDefinition.WorkerAssignment.OFFICE)
	assert_bool(result).is_true()

	# Allow one frame for signal processing
	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted()

	# Verify assignment changed
	var worker = worker_manager.get_worker_by_id(worker_id)
	assert_int(worker["assignment"]).is_equal(WorkerDefinition.WorkerAssignment.OFFICE)


func test_get_workers_by_assignment():
	# Test filtering workers by assignment
	# Setup and hire multiple workers
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 1000

	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.OFFICE)

	# Test filtering
	var kitchen_workers = worker_manager.get_workers_by_assignment(
		WorkerDefinition.WorkerAssignment.KITCHEN
	)
	var office_workers = worker_manager.get_workers_by_assignment(
		WorkerDefinition.WorkerAssignment.OFFICE
	)

	assert_int(kitchen_workers.size()).is_equal(1)
	assert_int(office_workers.size()).is_equal(1)


func test_production_rates():
	# Test worker production rate calculations
	# Setup and hire workers
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 1000

	# No workers initially
	assert_float(worker_manager.get_kitchen_production_rate()).is_equal(0.0)
	assert_float(worker_manager.get_total_consumption_rate()).is_equal(0.0)

	# Hire kitchen worker
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	assert_float(worker_manager.get_kitchen_production_rate()).is_equal(0.5)  # 0.5 per kitchen worker
	assert_float(worker_manager.get_total_consumption_rate()).is_equal(1.0)  # 1.0 per worker

	# Hire office worker (adds efficiency bonus)
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.OFFICE)
	assert_float(worker_manager.get_kitchen_production_rate()).is_equal(0.55)  # 0.5 * 1.1 (10% bonus)
	assert_float(worker_manager.get_total_consumption_rate()).is_equal(2.0)  # 2 workers total


func test_kitchen_worker_production():
	# Test kitchen worker production with sufficient hot dogs
	# Setup
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 100
	hot_dog_manager.hot_dogs_inventory = 10

	# Hire kitchen worker
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	var worker = worker_manager.hired_workers[0]

	# Process worker production
	worker_manager._process_kitchen_worker(worker)

	# Should consume 1 hot dog and accumulate 0.5 production
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(9)  # 10 - 1
	assert_float(worker["hot_dogs_consumed"]).is_equal(1.0)
	assert_float(worker["production_buffer"]).is_equal(0.5)
	assert_float(worker["hot_dogs_produced"]).is_equal(0.0)  # No whole hot dogs yet

	# Process again - should produce 1 hot dog from buffer
	worker_manager._process_kitchen_worker(worker)
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(9)  # 8 - 1 + 1 (produced)
	assert_float(worker["hot_dogs_produced"]).is_equal(1.0)
	assert_float(worker["production_buffer"]).is_equal(0.0)  # Buffer reset after production


func test_kitchen_worker_insufficient_hotdogs():
	# Test kitchen worker behavior with insufficient hot dogs
	# Setup
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 100
	hot_dog_manager.hot_dogs_inventory = 0  # No hot dogs

	# Hire kitchen worker
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	var worker = worker_manager.hired_workers[0]

	# Monitor signals using GdUnit4 approach
	var signal_monitor = monitor_signal(worker_manager, "worker_quota_warning")

	# Process worker production
	worker_manager._process_kitchen_worker(worker)

	# Should not consume or produce, but emit warning
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(0)
	assert_float(worker["hot_dogs_consumed"]).is_equal(0.0)
	assert_float(worker["hot_dogs_produced"]).is_equal(0.0)

	# Allow one frame for signal processing
	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted()


func test_office_worker_consumption():
	# Test office worker consumption
	# Setup
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 100
	hot_dog_manager.hot_dogs_inventory = 10

	# Hire office worker
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.OFFICE)
	var worker = worker_manager.hired_workers[0]

	# Process worker consumption once (0.5 hot dogs)
	worker_manager._process_office_worker(worker)
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(10)  # No consumption yet (buffer < 1.0)
	assert_float(worker["consumption_buffer"]).is_equal(0.5)

	# Process worker consumption again (1.0 hot dogs total)
	worker_manager._process_office_worker(worker)
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(9)  # Now consumes 1 hot dog
	assert_float(worker["hot_dogs_consumed"]).is_equal(1.0)
	assert_float(worker["consumption_buffer"]).is_equal(0.0)  # Buffer reset
	assert_bool(worker.has("hot_dogs_produced")).is_true()  # Should exist but be 0


func test_save_and_load():
	# Test save and load functionality
	# Setup and hire workers
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 1000

	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.OFFICE)

	# Get save data
	var save_data = worker_manager.get_save_data()
	assert_bool(save_data.has("workers")).is_true()
	assert_int(save_data["workers"]["hired_workers"].size()).is_equal(2)
	assert_int(save_data["workers"]["next_worker_id"]).is_equal(3)

	# Reset and load
	worker_manager.reset_workers()
	assert_int(worker_manager.get_worker_count()).is_equal(0)

	# Simulate loading save data
	worker_manager._on_save_data_loaded(save_data)
	assert_int(worker_manager.get_worker_count()).is_equal(2)
	assert_int(worker_manager.next_worker_id).is_equal(3)


func test_backward_compatibility():
	# Test backward compatibility for production buffer
	# Create worker data without production buffer (old save format)
	var old_worker_data = {
		"hired_workers":
		[
			{
				"worker_id": "worker_1",
				"display_name": "Worker 1",
				"assignment": WorkerDefinition.WorkerAssignment.KITCHEN,
				"hire_cost": 10,
				"hot_dogs_consumed": 0.0,
				"hot_dogs_produced": 0.0,
				"hire_time": "test_time"
				# No production_buffer or consumption_buffer fields
			}
		],
		"next_worker_id": 2,
		"max_workers": 2
	}

	# Load old save data
	worker_manager._on_save_data_loaded({"workers": old_worker_data})

	# Should automatically add production and consumption buffers
	var worker = worker_manager.hired_workers[0]
	assert_bool(worker.has("production_buffer")).is_true()
	assert_float(worker["production_buffer"]).is_equal(0.0)
	assert_bool(worker.has("consumption_buffer")).is_true()
	assert_float(worker["consumption_buffer"]).is_equal(0.0)


func test_get_worker_by_id():
	# Test worker retrieval by ID
	# Setup
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 100

	# Hire worker
	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	var worker_id = worker_manager.hired_workers[0]["worker_id"]

	# Test retrieval
	var worker = worker_manager.get_worker_by_id(worker_id)
	assert_dict(worker).is_not_empty()
	assert_str(worker["worker_id"]).is_equal(worker_id)

	# Test nonexistent worker
	var nonexistent = worker_manager.get_worker_by_id("nonexistent")
	assert_dict(nonexistent).is_empty()


func test_reset_workers():
	# Test worker reset functionality
	# Setup and hire workers
	building_manager.purchased_buildings["office"] = true
	hot_dog_manager.currency_balance = 1000

	worker_manager.hire_worker(WorkerDefinition.WorkerAssignment.KITCHEN)
	assert_int(worker_manager.get_worker_count()).is_equal(1)

	# Reset
	worker_manager.reset_workers()
	assert_int(worker_manager.get_worker_count()).is_equal(0)
	assert_array(worker_manager.hired_workers).is_empty()
	assert_int(worker_manager.next_worker_id).is_equal(1)
	assert_int(worker_manager.max_workers).is_equal(2)
