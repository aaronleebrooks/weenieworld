extends RefCounted
class_name GameData


# Default save data structure for Alien Hot Dog Food Truck
static func get_default_save_data() -> Dictionary:
	return {
		"truck_name": "My Food Truck",  # Default truck name
		"currency": 0,
		"hot_dogs_inventory": 0,
		"hot_dogs_per_click": 1,
		"production_rate": 0.3,
		"customer_purchase_rate": 2.0,
		"sale_value": 1,
		"total_hot_dogs_produced": 0,
		"total_hot_dogs_sold": 0,
		"total_currency_earned": 0,
		"total_clicks": 0,
		"play_time": 0,
		"upgrades_purchased": [],
		"last_save_time": "",
		"game_version": "1.0.0",
		"event_log": [],
		"max_events": 50
	}


# Upgrade definitions for hot dog store theme
static func get_upgrade_definitions() -> Dictionary:
	return {
		"faster_production":
		{
			"name": "Faster Production",
			"description": "Reduces production time by 0.02s",
			"base_cost": 10,
			"cost_multiplier": 1.5,
			"effect_multiplier": 1.2,
			"max_level": 10
		},
		"efficient_cooking":
		{
			"name": "Efficient Cooking",
			"description": "Reduces continuous production time by 0.05s",
			"base_cost": 50,
			"cost_multiplier": 1.8,
			"effect_multiplier": 1.1,
			"max_level": 5
		},
		"better_recipe":
		{
			"name": "Better Recipe",
			"description": "+1 hot dog per click",
			"base_cost": 25,
			"cost_multiplier": 1.6,
			"effect_multiplier": 1.0,
			"max_level": 8
		},
		"customer_service":
		{
			"name": "Customer Service",
			"description": "Customers arrive 0.2s faster",
			"base_cost": 75,
			"cost_multiplier": 1.7,
			"effect_multiplier": 1.1,
			"max_level": 6
		},
		"premium_pricing":
		{
			"name": "Premium Pricing",
			"description": "+1 currency per hot dog sold",
			"base_cost": 100,
			"cost_multiplier": 2.0,
			"effect_multiplier": 1.0,
			"max_level": 5
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
