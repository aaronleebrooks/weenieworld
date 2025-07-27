extends RefCounted
class_name GameData

# Default save data structure
static func get_default_save_data() -> Dictionary:
	return {
		"currency": 0,
		"click_value": 1,
		"auto_clicker_speed": 1.0,
		"total_earned": 0,
		"total_clicks": 0,
		"play_time": 0,
		"upgrades_purchased": [],
		"last_save_time": "",
		"game_version": "1.0.0"
	}

# Upgrade definitions
static func get_upgrade_definitions() -> Dictionary:
	return {
		"click_value": {
			"name": "Click Value",
			"description": "Increase currency earned per click",
			"base_cost": 10,
			"cost_multiplier": 1.5,
			"effect_multiplier": 1.2,
			"max_level": 100
		},
		"auto_clicker_speed": {
			"name": "Auto-Clicker Speed",
			"description": "Increase auto-clicker speed when holding",
			"base_cost": 25,
			"cost_multiplier": 1.8,
			"effect_multiplier": 1.1,
			"max_level": 50
		}
	}

# Calculate upgrade cost
static func calculate_upgrade_cost(upgrade_type: String, current_level: int) -> int:
	var definitions = get_upgrade_definitions()
	if not definitions.has(upgrade_type):
		return 0
	
	var upgrade = definitions[upgrade_type]
	return int(upgrade.base_cost * pow(upgrade.cost_multiplier, current_level))

# Calculate upgrade effect
static func calculate_upgrade_effect(upgrade_type: String, current_level: int) -> float:
	var definitions = get_upgrade_definitions()
	if not definitions.has(upgrade_type):
		return 1.0
	
	var upgrade = definitions[upgrade_type]
	return pow(upgrade.effect_multiplier, current_level) 