extends Node

# Upgrade system autoload for managing game upgrades
# Uses intentional naming conventions for future maintainability

const UpgradeEnums = preload("res://scripts/resources/UpgradeEnums.gd")
const UpgradeDefinition = preload("res://scripts/resources/UpgradeDefinition.gd")

signal upgrade_purchased(upgrade_id: String, level: int, cost: int)
signal upgrade_effect_applied(upgrade_id: String, effect_type: String, value: float)

# Upgrade tracking
var upgrade_levels: Dictionary = {}
var total_upgrades_purchased: int = 0

# References to other managers
var hot_dog_manager: Node
var customer_manager: Node

# Upgrade definitions (will be loaded from resources)
var upgrade_definitions: Array[UpgradeDefinition] = []

func _ready():
	print("UpgradeManager: Initialized")
	
	# Get references to other managers
	hot_dog_manager = get_node("/root/HotDogManager")
	customer_manager = get_node("/root/CustomerManager")
	
	# Load upgrade definitions
	_load_upgrade_definitions()
	
	# Initialize upgrade levels
	_initialize_upgrade_levels()
	
	# Connect to save system
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)

func _load_upgrade_definitions():
	"""Load upgrade definitions from resources"""
	# For now, create default upgrades
	# Later this will load from .tres files
	_create_default_upgrades()
	print("UpgradeManager: Loaded %d upgrade definitions" % upgrade_definitions.size())

func _create_default_upgrades():
	"""Create the initial 5 upgrades for the hot dog store theme"""
	
	# Production Rate Upgrades (2)
	var faster_production = UpgradeDefinition.new()
	faster_production.upgrade_id = "faster_production"
	faster_production.display_name = "Faster Production"
	faster_production.description = "Reduces production time by 0.02s"
	faster_production.base_cost = 10
	faster_production.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	faster_production.cost_increase = 5
	faster_production.effect_type = UpgradeEnums.EffectType.PRODUCTION_RATE
	faster_production.effect_value = -0.02
	faster_production.max_level = 10
	upgrade_definitions.append(faster_production)
	
	var efficient_cooking = UpgradeDefinition.new()
	efficient_cooking.upgrade_id = "efficient_cooking"
	efficient_cooking.display_name = "Efficient Cooking"
	efficient_cooking.description = "Reduces continuous production time by 0.05s"
	efficient_cooking.base_cost = 50
	efficient_cooking.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	efficient_cooking.cost_increase = 25
	efficient_cooking.effect_type = UpgradeEnums.EffectType.IDLE_RATE
	efficient_cooking.effect_value = -0.05
	efficient_cooking.max_level = 5
	upgrade_definitions.append(efficient_cooking)
	
	# Hot Dogs Per Click Upgrade (1)
	var better_recipe = UpgradeDefinition.new()
	better_recipe.upgrade_id = "better_recipe"
	better_recipe.display_name = "Better Recipe"
	better_recipe.description = "+1 hot dog per click"
	better_recipe.base_cost = 25
	better_recipe.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	better_recipe.cost_increase = 15
	better_recipe.effect_type = UpgradeEnums.EffectType.HOT_DOGS_PER_CLICK
	better_recipe.effect_value = 1
	better_recipe.max_level = 8
	upgrade_definitions.append(better_recipe)
	
	# Customer System Upgrades (2)
	var customer_service = UpgradeDefinition.new()
	customer_service.upgrade_id = "customer_service"
	customer_service.display_name = "Customer Service"
	customer_service.description = "Customers arrive 0.2s faster"
	customer_service.base_cost = 75
	customer_service.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	customer_service.cost_increase = 35
	customer_service.effect_type = UpgradeEnums.EffectType.CUSTOMER_PURCHASE_RATE
	customer_service.effect_value = -0.2
	customer_service.max_level = 6
	upgrade_definitions.append(customer_service)
	
	var premium_pricing = UpgradeDefinition.new()
	premium_pricing.upgrade_id = "premium_pricing"
	premium_pricing.display_name = "Premium Pricing"
	premium_pricing.description = "+1 currency per hot dog sold"
	premium_pricing.base_cost = 100
	premium_pricing.cost_scaling_type = UpgradeEnums.CostScalingType.EXPONENTIAL
	premium_pricing.cost_multiplier = 2.0
	premium_pricing.effect_type = UpgradeEnums.EffectType.SALE_VALUE
	premium_pricing.effect_value = 1
	premium_pricing.max_level = 5
	upgrade_definitions.append(premium_pricing)

func _initialize_upgrade_levels():
	"""Initialize upgrade levels to 0"""
	for upgrade in upgrade_definitions:
		upgrade_levels[upgrade.upgrade_id] = 0
	print("UpgradeManager: Initialized upgrade levels")

func _on_save_data_loaded(save_data: Dictionary):
	"""Load upgrade data from save file"""
	if save_data.has("upgrades"):
		var upgrades_data = save_data["upgrades"]
		upgrade_levels = upgrades_data.get("levels", {})
		total_upgrades_purchased = upgrades_data.get("total_purchased", 0)
		print("UpgradeManager: Loaded upgrade data from save")

func get_save_data() -> Dictionary:
	"""Get upgrade data for saving"""
	return {
		"upgrades": {
			"levels": upgrade_levels,
			"total_purchased": total_upgrades_purchased
		}
	}

func can_purchase_upgrade(upgrade_id: String) -> bool:
	"""Check if player can afford and purchase an upgrade"""
	var upgrade = _get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return false
	
	# Check if upgrade is at max level
	if upgrade.max_level > 0 and get_upgrade_level(upgrade_id) >= upgrade.max_level:
		return false
	
	# Check if player can afford the cost
	var cost = get_upgrade_cost(upgrade_id)
	return hot_dog_manager.can_afford(cost)

func purchase_upgrade(upgrade_id: String) -> bool:
	"""Purchase an upgrade and apply its effects"""
	if not can_purchase_upgrade(upgrade_id):
		return false
	
	var upgrade = _get_upgrade_by_id(upgrade_id)
	var cost = get_upgrade_cost(upgrade_id)
	
	# Deduct currency
	if not hot_dog_manager.spend_currency(cost, "upgrade_purchase"):
		return false
	
	# Increase upgrade level
	upgrade_levels[upgrade_id] += 1
	total_upgrades_purchased += 1
	
	# Apply upgrade effects
	_apply_upgrade_effects(upgrade_id)
	
	# Emit signals
	emit_signal("upgrade_purchased", upgrade_id, upgrade_levels[upgrade_id], cost)
	
	# Add event to event log
	var event_log_manager = get_node_or_null("/root/EventLogManager")
	if event_log_manager:
		event_log_manager.add_purchase_event(upgrade.display_name, cost, "upgrade")
	
	print("UpgradeManager: Purchased %s (level %d) for %d currency" % [upgrade.display_name, upgrade_levels[upgrade_id], cost])
	return true

func get_upgrade_cost(upgrade_id: String) -> int:
	"""Calculate the cost of an upgrade at its current level"""
	var upgrade = _get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return 0
	
	var level = get_upgrade_level(upgrade_id)
	
	match upgrade.cost_scaling_type:
		UpgradeEnums.CostScalingType.LINEAR:
			return upgrade.base_cost + (level * upgrade.cost_increase)
		UpgradeEnums.CostScalingType.EXPONENTIAL:
			return int(upgrade.base_cost * pow(upgrade.cost_multiplier, level))
		UpgradeEnums.CostScalingType.CURVED:
			return int(upgrade.base_cost * (1 + level * upgrade.cost_curve_factor))
		_:
			return upgrade.base_cost

func get_upgrade_level(upgrade_id: String) -> int:
	"""Get the current level of an upgrade"""
	return upgrade_levels.get(upgrade_id, 0)

func _get_upgrade_by_id(upgrade_id: String) -> UpgradeDefinition:
	"""Get upgrade definition by ID"""
	for upgrade in upgrade_definitions:
		if upgrade.upgrade_id == upgrade_id:
			return upgrade
	return null

func _apply_upgrade_effects(upgrade_id: String):
	"""Apply the effects of an upgrade"""
	var upgrade = _get_upgrade_by_id(upgrade_id)
	if not upgrade or not hot_dog_manager or not customer_manager:
		return
	
	var level = get_upgrade_level(upgrade_id)
	var total_effect = upgrade.effect_value * level
	
	match upgrade.effect_type:
		UpgradeEnums.EffectType.HOT_DOGS_PER_CLICK:
			hot_dog_manager.hot_dogs_per_click = 1 + total_effect
			emit_signal("upgrade_effect_applied", upgrade_id, "hot_dogs_per_click", total_effect)
		UpgradeEnums.EffectType.PRODUCTION_RATE:
			hot_dog_manager.production_rate_seconds = max(0.05, 0.3 + total_effect)
			emit_signal("upgrade_effect_applied", upgrade_id, "production_rate", total_effect)
		UpgradeEnums.EffectType.IDLE_RATE:
			hot_dog_manager.idle_rate_seconds = max(0.1, 0.3 + total_effect)
			emit_signal("upgrade_effect_applied", upgrade_id, "idle_rate", total_effect)
		UpgradeEnums.EffectType.CUSTOMER_PURCHASE_RATE:
			customer_manager.set_purchase_rate(max(0.5, 2.0 + total_effect))
			emit_signal("upgrade_effect_applied", upgrade_id, "customer_purchase_rate", total_effect)
		UpgradeEnums.EffectType.SALE_VALUE:
			hot_dog_manager.sale_value = 1 + total_effect
			emit_signal("upgrade_effect_applied", upgrade_id, "sale_value", total_effect)
	
	# Force update the game display to show new values immediately
	var game = get_node_or_null("/root/Game")
	if game and game.has_method("display_game_data"):
		game.display_game_data()

func get_all_upgrades() -> Array[UpgradeDefinition]:
	"""Get all upgrade definitions"""
	return upgrade_definitions

func get_upgrade_info(upgrade_id: String) -> Dictionary:
	"""Get comprehensive information about an upgrade"""
	var upgrade = _get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return {}
	
	var level = get_upgrade_level(upgrade_id)
	var cost = get_upgrade_cost(upgrade_id)
	var can_purchase = can_purchase_upgrade(upgrade_id)
	var is_max_level = upgrade.max_level > 0 and level >= upgrade.max_level
	
	return {
		"upgrade": upgrade,
		"level": level,
		"cost": cost,
		"can_purchase": can_purchase,
		"is_max_level": is_max_level
	}

func reset_upgrades():
	"""Reset all upgrades to level 0"""
	upgrade_levels.clear()
	_initialize_upgrade_levels()
	total_upgrades_purchased = 0
	print("UpgradeManager: Reset all upgrades") 