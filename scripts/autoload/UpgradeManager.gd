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
var currency_manager: Node

# Upgrade definitions (will be loaded from resources)
var upgrade_definitions: Array[UpgradeDefinition] = []

func _ready():
	print("UpgradeManager: Initialized")
	
	# Get references to other managers
	currency_manager = get_node("/root/CurrencyManager")
	
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
	"""Create the initial 5 upgrades as defined in the plan"""
	
	# Click Rate Upgrades (2)
	var faster_fingers = UpgradeDefinition.new()
	faster_fingers.upgrade_id = "faster_fingers"
	faster_fingers.display_name = "Faster Fingers"
	faster_fingers.description = "Reduces click rate by 0.02s"
	faster_fingers.base_cost = 10
	faster_fingers.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	faster_fingers.cost_increase = 5
	faster_fingers.effect_type = UpgradeEnums.EffectType.CLICK_RATE
	faster_fingers.effect_value = -0.02
	faster_fingers.max_level = 10
	upgrade_definitions.append(faster_fingers)
	
	var lightning_clicks = UpgradeDefinition.new()
	lightning_clicks.upgrade_id = "lightning_clicks"
	lightning_clicks.display_name = "Lightning Clicks"
	lightning_clicks.description = "Reduces click rate by 0.05s"
	lightning_clicks.base_cost = 50
	lightning_clicks.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	lightning_clicks.cost_increase = 25
	lightning_clicks.effect_type = UpgradeEnums.EffectType.CLICK_RATE
	lightning_clicks.effect_value = -0.05
	lightning_clicks.max_level = 5
	upgrade_definitions.append(lightning_clicks)
	
	# Idle Rate Upgrades (2)
	var patience_training = UpgradeDefinition.new()
	patience_training.upgrade_id = "patience_training"
	patience_training.display_name = "Patience Training"
	patience_training.description = "Reduces idle rate by 0.05s"
	patience_training.base_cost = 25
	patience_training.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	patience_training.cost_increase = 15
	patience_training.effect_type = UpgradeEnums.EffectType.IDLE_RATE
	patience_training.effect_value = -0.05
	patience_training.max_level = 8
	upgrade_definitions.append(patience_training)
	
	var steady_hands = UpgradeDefinition.new()
	steady_hands.upgrade_id = "steady_hands"
	steady_hands.display_name = "Steady Hands"
	steady_hands.description = "Reduces idle rate by 0.1s"
	steady_hands.base_cost = 100
	steady_hands.cost_scaling_type = UpgradeEnums.CostScalingType.LINEAR
	steady_hands.cost_increase = 50
	steady_hands.effect_type = UpgradeEnums.EffectType.IDLE_RATE
	steady_hands.effect_value = -0.1
	steady_hands.max_level = 3
	upgrade_definitions.append(steady_hands)
	
	# Currency Per Click Upgrade (1)
	var better_technique = UpgradeDefinition.new()
	better_technique.upgrade_id = "better_technique"
	better_technique.display_name = "Better Technique"
	better_technique.description = "+1 currency per click"
	better_technique.base_cost = 75
	better_technique.cost_scaling_type = UpgradeEnums.CostScalingType.EXPONENTIAL
	better_technique.cost_multiplier = 2.0
	better_technique.effect_type = UpgradeEnums.EffectType.CURRENCY_PER_CLICK
	better_technique.effect_value = 1
	better_technique.max_level = 5
	upgrade_definitions.append(better_technique)

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
	return currency_manager.can_afford(cost)

func purchase_upgrade(upgrade_id: String) -> bool:
	"""Purchase an upgrade and apply its effects"""
	if not can_purchase_upgrade(upgrade_id):
		return false
	
	var upgrade = _get_upgrade_by_id(upgrade_id)
	var cost = get_upgrade_cost(upgrade_id)
	
	# Deduct currency
	if not currency_manager.spend_currency(cost, "upgrade_purchase"):
		return false
	
	# Increase upgrade level
	upgrade_levels[upgrade_id] += 1
	total_upgrades_purchased += 1
	
	# Apply upgrade effects
	_apply_upgrade_effects(upgrade_id)
	
	# Emit signals
	emit_signal("upgrade_purchased", upgrade_id, upgrade_levels[upgrade_id], cost)
	
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
	if not upgrade or not currency_manager:
		return
	
	var level = get_upgrade_level(upgrade_id)
	var total_effect = upgrade.effect_value * level
	
	match upgrade.effect_type:
		UpgradeEnums.EffectType.CURRENCY_PER_CLICK:
			currency_manager.currency_per_click = 1 + total_effect
			emit_signal("upgrade_effect_applied", upgrade_id, "currency_per_click", total_effect)
		UpgradeEnums.EffectType.CLICK_RATE:
			currency_manager.click_rate_seconds = max(0.05, 0.1 + total_effect)
			emit_signal("upgrade_effect_applied", upgrade_id, "click_rate", total_effect)
		UpgradeEnums.EffectType.IDLE_RATE:
			currency_manager.idle_rate_seconds = max(0.1, 0.3 + total_effect)
			emit_signal("upgrade_effect_applied", upgrade_id, "idle_rate", total_effect)
		UpgradeEnums.EffectType.CURRENCY_MULTIPLIER:
			# This would be applied to all currency gains
			emit_signal("upgrade_effect_applied", upgrade_id, "currency_multiplier", total_effect)
	
	# Force update the game display to show new values immediately
	var game = get_node_or_null("/root/Game")
	if game and game.has_method("display_game_data"):
		game.display_game_data()

func get_all_upgrades() -> Array[UpgradeDefinition]:
	"""Get all upgrade definitions"""
	return upgrade_definitions

func get_upgrade_info(upgrade_id: String) -> Dictionary:
	"""Get comprehensive info about an upgrade"""
	var upgrade = _get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return {}
	
	var level = get_upgrade_level(upgrade_id)
	var cost = get_upgrade_cost(upgrade_id)
	var can_afford = currency_manager.can_afford(cost)
	var is_max_level = upgrade.max_level > 0 and level >= upgrade.max_level
	
	return {
		"upgrade": upgrade,
		"level": level,
		"cost": cost,
		"can_afford": can_afford,
		"is_max_level": is_max_level,
		"can_purchase": can_afford and not is_max_level
	}

func reset_upgrades():
	"""Reset all upgrades to level 0 (for new game)"""
	upgrade_levels.clear()
	_initialize_upgrade_levels()
	total_upgrades_purchased = 0
	print("UpgradeManager: Reset all upgrades") 