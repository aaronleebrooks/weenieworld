extends Control

# Debug panel for manual currency and hot dog addition during development
# Provides quick actions for testing office purchase and worker systems
# Only available in development builds

@onready var currency_input = $MainContainer/CurrencySection/CurrencyInput
@onready var hot_dog_input = $MainContainer/HotDogSection/HotDogInput
@onready var add_currency_button = $MainContainer/CurrencySection/AddCurrencyButton
@onready var add_hot_dog_button = $MainContainer/HotDogSection/AddHotDogButton
@onready var unlock_office_button = $MainContainer/QuickActions/UnlockOfficeButton
@onready var hire_worker_button = $MainContainer/QuickActions/HireWorkerButton
@onready var close_button = $MainContainer/CloseButton

var hot_dog_manager: Node
var building_manager: Node
var worker_manager: Node
var event_log_manager: Node

# Debug mode constants
const DEBUG_MODE: bool = true  # Set to false for production builds
const DEBUG_SOURCE: String = "debug_panel"  # Source identifier for debug actions
const OFFICE_UNLOCK_CURRENCY: int = 600  # 100 to unlock + 500 to purchase
const WORKER_SETUP_CURRENCY: int = 20
const WORKER_SETUP_HOT_DOGS: int = 10


func _ready():
	print("DebugPanel: Initialized")

	# Hide if not in debug mode
	if not DEBUG_MODE:
		visible = false
		return

	# Get references to managers using helper method
	hot_dog_manager = _get_manager("HotDogManager")
	building_manager = _get_manager("BuildingManager")
	worker_manager = _get_manager("WorkerManager")
	event_log_manager = _get_manager("EventLogManager")

	# Connect button signals
	add_currency_button.pressed.connect(_on_add_currency_button_pressed)
	add_hot_dog_button.pressed.connect(_on_add_hot_dog_button_pressed)
	unlock_office_button.pressed.connect(_on_unlock_office_button_pressed)
	hire_worker_button.pressed.connect(_on_hire_worker_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)

	# Start hidden
	visible = false

	print("DebugPanel: Ready for debug actions")


func _input(event):
	"""Handle debug panel toggle with F12 key"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			toggle_debug_panel()


func toggle_debug_panel():
	"""Toggle debug panel visibility"""
	if not DEBUG_MODE:
		return

	visible = not visible
	if visible:
		print("DebugPanel: Opened")
	else:
		print("DebugPanel: Closed")


func show_debug_panel():
	"""Show the debug panel"""
	if DEBUG_MODE:
		visible = true


func _on_add_currency_button_pressed():
	"""Handle add currency button press"""
	var amount = int(currency_input.value)
	if _add_debug_currency(amount):
		print("DebugPanel: Successfully added %d currency" % amount)
		_log_debug_action("Added %d currency via debug panel" % amount)
	else:
		print("DebugPanel: Failed to add currency")


func _on_add_hot_dog_button_pressed():
	"""Handle add hot dog button press"""
	var amount = int(hot_dog_input.value)
	if _add_debug_hot_dogs(amount):
		print("DebugPanel: Successfully added %d hot dogs" % amount)
		_log_debug_action("Added %d hot dogs via debug panel" % amount)
	else:
		print("DebugPanel: Failed to add hot dogs")


func _on_unlock_office_button_pressed():
	"""Handle quick office unlock button press"""
	if _quick_office_unlock():
		print("DebugPanel: Successfully unlocked office for testing")
		_log_debug_action(
			"Quick office unlock - added %d currency for testing" % OFFICE_UNLOCK_CURRENCY
		)
	else:
		print("DebugPanel: Failed to unlock office")


func _on_hire_worker_button_pressed():
	"""Handle quick worker hire button press"""
	if _quick_worker_setup():
		print("DebugPanel: Successfully set up worker hiring conditions")
		_log_debug_action(
			(
				"Quick worker setup - added %d currency and %d hot dogs"
				% [WORKER_SETUP_CURRENCY, WORKER_SETUP_HOT_DOGS]
			)
		)
	else:
		print("DebugPanel: Failed to set up worker conditions")


func _on_close_button_pressed():
	"""Handle close button press"""
	visible = false


func _add_debug_currency(amount: int) -> bool:
	"""Add currency through debug system with validation"""
	if not hot_dog_manager:
		print("DebugPanel: HotDogManager not available")
		return false

	if not _validate_debug_input(amount):
		return false

	# Use the proper method to add currency
	return hot_dog_manager.add_currency(amount, DEBUG_SOURCE)


func _add_debug_hot_dogs(amount: int) -> bool:
	"""Add hot dogs through debug system with validation"""
	if not hot_dog_manager:
		print("DebugPanel: HotDogManager not available")
		return false

	if not _validate_debug_input(amount):
		return false

	# Use the existing produce_hot_dogs method to maintain consistency
	hot_dog_manager.produce_hot_dogs(amount, DEBUG_SOURCE)

	return true


func _quick_office_unlock() -> bool:
	"""Quick action to provide enough currency for office unlock and purchase"""
	if not hot_dog_manager:
		print("DebugPanel: HotDogManager not available")
		return false

	# Check if office is already unlocked
	if building_manager and building_manager.is_building_purchased("office"):
		print("DebugPanel: Office already purchased")
		return false

	# Add enough currency to unlock (100) and purchase (500) office
	return _add_debug_currency(OFFICE_UNLOCK_CURRENCY)


func _quick_worker_setup() -> bool:
	"""Quick action to provide resources for worker hiring"""
	if not hot_dog_manager:
		print("DebugPanel: HotDogManager not available")
		return false

	# Check if office is purchased (required for workers)
	if not building_manager or not building_manager.is_building_purchased("office"):
		print("DebugPanel: Office must be purchased before hiring workers")
		return false

	# Add currency for worker hiring and hot dogs for worker consumption
	var currency_success = _add_debug_currency(WORKER_SETUP_CURRENCY)
	var hot_dog_success = _add_debug_hot_dogs(WORKER_SETUP_HOT_DOGS)

	return currency_success and hot_dog_success


func _validate_debug_input(amount: int) -> bool:
	"""Validate debug input amount"""
	if amount <= 0:
		print("DebugPanel: Invalid amount - must be positive")
		return false

	if amount > 999999:
		print("DebugPanel: Invalid amount - too large (max 999999)")
		return false

	return true


func _log_debug_action(action: String):
	"""Log debug action in event system"""
	if event_log_manager:
		# Use the new debug event method
		event_log_manager.add_debug_event(action)
	else:
		print("DebugPanel: EventLogManager not available for logging")


func get_debug_info() -> Dictionary:
	"""Get current debug information for display"""
	var info = {}

	if hot_dog_manager:
		info["currency"] = hot_dog_manager.currency_balance
		info["total_currency_earned"] = hot_dog_manager.total_currency_earned
		info["hot_dogs"] = hot_dog_manager.hot_dogs_inventory

	if building_manager:
		info["office_purchased"] = building_manager.is_building_purchased("office")
		info["office_unlocked"] = building_manager.is_building_unlocked("office")

	if worker_manager:
		info["worker_count"] = worker_manager.get_worker_count()
		info["can_hire_worker"] = worker_manager.can_hire_worker()

	return info


func update_quick_action_buttons():
	"""Update quick action button states based on current game state"""
	if not DEBUG_MODE:
		return

	var info = get_debug_info()

	# Update office unlock button
	if unlock_office_button:
		if info.get("office_purchased", false):
			unlock_office_button.text = "Office Already Purchased ✓"
			unlock_office_button.disabled = true
		else:
			unlock_office_button.text = "Quick Office Unlock (%d currency)" % OFFICE_UNLOCK_CURRENCY
			unlock_office_button.disabled = false

	# Update worker hire button
	if hire_worker_button:
		if not info.get("office_purchased", false):
			hire_worker_button.text = "Need Office First"
			hire_worker_button.disabled = true
		else:
			hire_worker_button.text = (
				"Quick Worker Setup (%d currency + %d hot dogs)"
				% [WORKER_SETUP_CURRENCY, WORKER_SETUP_HOT_DOGS]
			)
			hire_worker_button.disabled = false


func _get_manager(manager_name: String) -> Node:
	"""Helper method to get manager references with consistent path pattern"""
	return get_node_or_null("/root/" + manager_name)


func _on_visibility_changed():
	"""Update button states when panel becomes visible"""
	if visible:
		update_quick_action_buttons()
