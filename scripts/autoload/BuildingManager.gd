extends Node

# Building management system autoload for managing building purchases
# Uses intentional naming conventions for future maintainability

const BuildingDefinition = preload("res://scripts/resources/BuildingDefinition.gd")

# Signals
signal building_purchased(building_id: String, cost: int)
signal building_unlocked(building_id: String)

# Building tracking
var purchased_buildings: Dictionary = {}  # building_id -> purchased (bool)
var building_definitions: Array[BuildingDefinition] = []

# References to other managers
var hot_dog_manager: Node
var upgrade_manager: Node

const DEBUG_MODE: bool = false

func _ready():
	print("BuildingManager: Initialized")
	
	# Get references to other managers
	hot_dog_manager = get_node_or_null("/root/HotDogManager")
	upgrade_manager = get_node_or_null("/root/UpgradeManager")
	
	# Load building definitions
	_load_building_definitions()
	
	# Initialize building states
	_initialize_building_states()
	
	# Connect to save system
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)

func _load_building_definitions():
	"""Load building definitions"""
	# For now, create default buildings
	# Later this will load from .tres files
	_create_default_buildings()
	print("BuildingManager: Loaded %d building definitions" % building_definitions.size())

func _create_default_buildings():
	"""Create the initial building definitions"""
	
	# Office Building
	var office = BuildingDefinition.new()
	office.building_id = "office"
	office.display_name = "Office"
	office.description = "A place to focus. Unlock the ability to hire workers for your food truck."
	office.base_cost = 500
	office.unlock_condition_type = BuildingDefinition.UnlockConditionType.CURRENCY_EARNED
	office.unlock_condition_value = 100
	office.effects = [
		"Unlock worker hiring system",
		"Enable worker station assignments",
		"Access to worker-specific upgrades"
	]
	building_definitions.append(office)

func _initialize_building_states():
	"""Initialize building purchase states"""
	for building in building_definitions:
		purchased_buildings[building.building_id] = false
	print("BuildingManager: Initialized building states")

func _on_save_data_loaded(save_data: Dictionary):
	"""Load building data from save file"""
	if save_data.has("buildings"):
		var buildings_data = save_data["buildings"]
		purchased_buildings = buildings_data.get("purchased", {})
		print("BuildingManager: Loaded building data from save")

func get_save_data() -> Dictionary:
	"""Get building data for saving"""
	return {"buildings": {"purchased": purchased_buildings}}

func can_purchase_building(building_id: String) -> bool:
	"""Check if player can purchase a building"""
	var building = _get_building_by_id(building_id)
	if not building:
		return false
	
	# Check if already purchased
	if is_building_purchased(building_id):
		return false
	
	# Check unlock conditions
	if not is_building_unlocked(building_id):
		return false
	
	# Check affordability
	if not hot_dog_manager or not hot_dog_manager.can_afford(building.base_cost):
		return false
	
	return true

func purchase_building(building_id: String) -> bool:
	"""Purchase a building and apply its effects"""
	if not can_purchase_building(building_id):
		return false
	
	var building = _get_building_by_id(building_id)
	var cost = building.base_cost
	
	# Deduct currency
	if not hot_dog_manager.spend_currency(cost, "building_purchase"):
		return false
	
	# Mark as purchased
	purchased_buildings[building_id] = true
	
	# Apply building effects (will be expanded as we add more buildings)
	_apply_building_effects(building_id)
	
	# Emit signals
	emit_signal("building_purchased", building_id, cost)
	
	# Add event to event log
	var event_log_manager = get_node_or_null("/root/EventLogManager")
	if event_log_manager:
		event_log_manager.add_purchase_event(building.display_name, cost, "building")
	
	print("BuildingManager: Purchased %s for %d currency" % [building.display_name, cost])
	return true

func is_building_purchased(building_id: String) -> bool:
	"""Check if a building has been purchased"""
	return purchased_buildings.get(building_id, false)

func is_building_unlocked(building_id: String) -> bool:
	"""Check if a building meets its unlock conditions"""
	var building = _get_building_by_id(building_id)
	if not building:
		return false
	
	match building.unlock_condition_type:
		BuildingDefinition.UnlockConditionType.CURRENCY_EARNED:
			if hot_dog_manager:
				return hot_dog_manager.total_currency_earned >= building.unlock_condition_value
		BuildingDefinition.UnlockConditionType.BUILDINGS_OWNED:
			return get_purchased_building_count() >= building.unlock_condition_value
		BuildingDefinition.UnlockConditionType.UPGRADES_PURCHASED:
			if upgrade_manager:
				return upgrade_manager.total_upgrades_purchased >= building.unlock_condition_value
		_:
			return true
	
	return false

func get_purchased_building_count() -> int:
	"""Get the total number of purchased buildings"""
	var count = 0
	for purchased in purchased_buildings.values():
		if purchased:
			count += 1
	return count

func _get_building_by_id(building_id: String) -> BuildingDefinition:
	"""Get building definition by ID"""
	for building in building_definitions:
		if building.building_id == building_id:
			return building
	return null

func _apply_building_effects(building_id: String):
	"""Apply the effects of purchasing a building"""
	match building_id:
		"office":
			# Office unlocks worker system
			# This will be implemented when WorkerManager is created
			print("BuildingManager: Office purchased - worker system unlocked")
		_:
			if DEBUG_MODE:
				print("BuildingManager: No specific effects for building: ", building_id)

func get_all_buildings() -> Array[BuildingDefinition]:
	"""Get all building definitions"""
	return building_definitions

func get_building_info(building_id: String) -> Dictionary:
	"""Get comprehensive information about a building"""
	var building = _get_building_by_id(building_id)
	if not building:
		return {}
	
	var is_purchased = is_building_purchased(building_id)
	var is_unlocked = is_building_unlocked(building_id)
	var can_purchase = can_purchase_building(building_id)
	
	return {
		"building": building,
		"is_purchased": is_purchased,
		"is_unlocked": is_unlocked,
		"can_purchase": can_purchase
	}

func reset_buildings():
	"""Reset all buildings to unpurchased state (for new game)"""
	purchased_buildings.clear()
	_initialize_building_states()
	print("BuildingManager: Reset to starting values")