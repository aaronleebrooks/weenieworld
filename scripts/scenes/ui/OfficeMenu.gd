extends Control

# Office Management Menu
# Provides interface for worker management and station overview

const DEBUG_MODE: bool = false

@onready var close_button = $MainContainer/Header/CloseButton
@onready var status_label = $MainContainer/Content/VBoxContainer/OfficeStatus/StatusLabel
@onready var worker_stats = $MainContainer/Content/VBoxContainer/WorkerSection/WorkerStats
@onready var hire_worker_button = $MainContainer/Content/VBoxContainer/WorkerSection/HireWorkerButton
@onready var worker_list = $MainContainer/Content/VBoxContainer/WorkerList
@onready var kitchen_label = $MainContainer/Content/VBoxContainer/StationSection/KitchenStation/KitchenLabel
@onready var kitchen_status = $MainContainer/Content/VBoxContainer/StationSection/KitchenStation/KitchenStatus
@onready var office_label = $MainContainer/Content/VBoxContainer/StationSection/OfficeStation/OfficeLabel
@onready var office_status = $MainContainer/Content/VBoxContainer/StationSection/OfficeStation/OfficeStatus

# References to managers
var building_manager: Node
var worker_manager: Node
var hot_dog_manager: Node

# Worker UI elements
var worker_buttons: Array[Button] = []


func _ready():
	if DEBUG_MODE:
		print("OfficeMenu: _ready() called")

	# Get references to managers
	building_manager = get_node_or_null("/root/BuildingManager")
	worker_manager = get_node_or_null("/root/WorkerManager")
	hot_dog_manager = get_node_or_null("/root/HotDogManager")

	# Verify UI nodes exist before connecting signals
	if not close_button:
		push_error("OfficeMenu: Close button not found!")
		return
	if not hire_worker_button:
		push_error("OfficeMenu: Hire worker button not found!")
		return

	# Connect signals
	close_button.pressed.connect(_on_close_button_pressed)
	hire_worker_button.pressed.connect(_on_hire_worker_button_pressed)

	# Connect to manager signals
	if worker_manager:
		worker_manager.worker_hired.connect(_on_worker_hired)
		worker_manager.worker_assigned.connect(_on_worker_assigned)
		worker_manager.production_rates_changed.connect(_on_production_rates_changed)

	if building_manager:
		building_manager.building_purchased.connect(_on_building_purchased)

	# Initial update
	_update_office_status()
	_update_worker_management()
	_update_station_overview()


func _on_close_button_pressed():
	"""Close the office menu"""
	visible = false


func _on_hire_worker_button_pressed():
	"""Handle hire worker button press"""
	if not worker_manager:
		return

	if worker_manager.hire_worker():
		print("OfficeMenu: Successfully hired worker")
		_update_worker_management()
	else:
		print("OfficeMenu: Failed to hire worker")


func _on_worker_hired(worker_id: String, cost: int):
	"""Handle worker hired event"""
	_update_worker_management()
	_update_station_overview()


func _on_worker_assigned(worker_id: String, assignment: int):
	"""Handle worker assignment event"""
	_update_worker_management()
	_update_station_overview()


func _on_production_rates_changed():
	"""Handle production rate changes"""
	_update_station_overview()


func _on_building_purchased(building_id: String, cost: int):
	"""Handle building purchase event"""
	if building_id == "office":
		_update_office_status()


func _update_office_status():
	"""Update office status display"""
	if not building_manager:
		return

	var office_purchased = building_manager.is_building_purchased("office")
	if office_purchased:
		status_label.text = "Office Status: 🟢 Operational"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Office Status: 🔴 Not Purchased"
		status_label.modulate = Color.RED


func _update_worker_management():
	"""Update worker management section"""
	if not worker_manager or not building_manager:
		return

	# Check if office is purchased
	if not building_manager.is_building_purchased("office"):
		worker_stats.text = "Workers: Office not purchased"
		hire_worker_button.text = "Need Office First"
		hire_worker_button.disabled = true
		return

	# Update worker stats
	var total_workers = worker_manager.get_total_worker_count()
	var max_workers = worker_manager.get_max_workers()
	worker_stats.text = "Workers: %d/%d" % [total_workers, max_workers]

	# Update hire button
	if worker_manager.can_hire_worker():
		var hire_cost = worker_manager.get_next_hire_cost()
		hire_worker_button.text = "Hire Worker (%d currency)" % hire_cost
		hire_worker_button.disabled = false
	else:
		hire_worker_button.text = "Max Workers Hired"
		hire_worker_button.disabled = true

	# Update worker list
	_update_worker_list()


func _update_worker_list():
	"""Update the list of worker buttons"""
	# Clear existing worker buttons
	for button in worker_buttons:
		if is_instance_valid(button):
			button.queue_free()
	worker_buttons.clear()

	if not worker_manager:
		return

	# Create buttons for each worker
	var workers = worker_manager.get_all_workers()
	for worker in workers:
		var button = _create_worker_button(worker)
		worker_list.add_child(button)
		worker_buttons.append(button)


func _create_worker_button(worker: Dictionary) -> Button:
	"""Create a button for a specific worker"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	button.text = _get_worker_button_text(worker)
	button.pressed.connect(_on_worker_button_pressed.bind(worker["worker_id"]))

	# Store worker info in button metadata
	button.set_meta("worker_id", worker["worker_id"])

	return button


func _get_worker_button_text(worker: Dictionary) -> String:
	"""Get the text for a worker button"""
	var assignment = "Kitchen" if worker["assignment"] == 0 else "Office"
	return "Worker %s - %s (Click to reassign)" % [worker["worker_id"], assignment]


func _on_worker_button_pressed(worker_id: String):
	"""Handle worker button press (reassign worker)"""
	if not worker_manager:
		return

	var worker = worker_manager.get_worker_by_id(worker_id)
	if worker.is_empty():
		return

	# Toggle assignment between Kitchen and Office
	var new_assignment = 1 if worker["assignment"] == 0 else 0
	worker_manager.assign_worker(worker_id, new_assignment)


func _update_station_overview():
	"""Update station overview section"""
	if not worker_manager:
		return

	# Update kitchen station
	var kitchen_workers = worker_manager.get_workers_by_assignment(0)  # Kitchen
	kitchen_label.text = "Kitchen: %d workers" % kitchen_workers.size()
	
	if kitchen_workers.size() > 0:
		var production_rate = worker_manager.get_kitchen_production_rate()
		kitchen_status.text = "🟢 %.1f hot dogs/s" % production_rate
	else:
		kitchen_status.text = "⚪ Idle"

	# Update office station
	var office_workers = worker_manager.get_workers_by_assignment(1)  # Office
	office_label.text = "Office: %d workers" % office_workers.size()
	
	if office_workers.size() > 0:
		var efficiency_bonus = worker_manager.get_office_efficiency_bonus()
		office_status.text = "🟢 +%.0f%% efficiency" % ((efficiency_bonus - 1.0) * 100)
	else:
		office_status.text = "⚪ Idle"


func show_menu():
	"""Show the office menu and update all displays"""
	visible = true
	_update_office_status()
	_update_worker_management()
	_update_station_overview() 
