extends Node

# Save system autoload for managing game saves
# Uses intentional naming conventions for future maintainability

signal save_data_loaded(save_data: Dictionary)
signal save_created(save_name: String)
signal save_deleted(save_name: String)

# Save configuration
var save_directory: String = "user://saves/"
var autosave_name: String = "autosave"
var max_manual_saves: int = 3

# References to managers
var hot_dog_manager: Node
var customer_manager: Node
var upgrade_manager: Node
var game_manager: Node


func _ready():
	print("SaveSystem: Initialized")

	# Get references to other managers
	hot_dog_manager = get_node("/root/HotDogManager")
	customer_manager = get_node("/root/CustomerManager")
	upgrade_manager = get_node("/root/UpgradeManager")
	game_manager = get_node("/root/GameManager")

	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(save_directory)

	# Start autosave timer
	_start_autosave_timer()


func _start_autosave_timer():
	"""Start the autosave timer"""
	var autosave_timer = Timer.new()
	autosave_timer.wait_time = 30.0  # 30 seconds
	autosave_timer.timeout.connect(_perform_autosave)
	add_child(autosave_timer)
	autosave_timer.start()
	print("SaveSystem: Autosave timer started (30s interval)")


func _perform_autosave():
	"""Perform automatic save"""
	if game_manager and game_manager.get_game_active():
		save_game(autosave_name)
		print("SaveSystem: Autosave completed")


func save_game(save_name: String) -> bool:
	"""Save the current game state"""
	var save_data = _collect_save_data()
	var file_path = save_directory + save_name + ".json"

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()

		print("SaveSystem: Game saved to %s" % file_path)
		emit_signal("save_created", save_name)
		return true

	print("SaveSystem: Failed to save game to %s" % file_path)
	return false


func load_game(save_name: String) -> bool:
	"""Load a game save"""
	var file_path = save_directory + save_name + ".json"

	if not FileAccess.file_exists(file_path):
		print("SaveSystem: Save file not found: %s" % file_path)
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var save_data = json.data
			_apply_save_data(save_data)
			print("SaveSystem: Game loaded from %s" % file_path)
			emit_signal("save_data_loaded", save_data)
			return true

		print("SaveSystem: Failed to parse save file: %s" % file_path)
		return false

	print("SaveSystem: Failed to open save file: %s" % file_path)
	return false


func delete_save(save_name: String) -> bool:
	"""Delete a save file"""
	var file_path = save_directory + save_name + ".json"

	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open(save_directory)
		if dir:
			var result = dir.remove(save_name + ".json")
			if result == OK:
				print("SaveSystem: Save deleted: %s" % save_name)
				emit_signal("save_deleted", save_name)
				return true

			print("SaveSystem: Failed to delete save: %s" % save_name)
			return false

		print("SaveSystem: Failed to access save directory")
		return false

	print("SaveSystem: Save file not found: %s" % save_name)
	return false


func get_save_list() -> Array[Dictionary]:
	"""Get list of available saves with metadata"""
	var saves: Array[Dictionary] = []
	var dir = DirAccess.open(save_directory)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with(".json"):
				var save_name = file_name.get_basename()
				var file_path = save_directory + file_name
				var file_info = FileAccess.get_modified_time(file_path)

				saves.append(
					{
						"name": save_name,
						"modified_time": file_info,
						"is_autosave": save_name == autosave_name
					}
				)

			file_name = dir.get_next()

		dir.list_dir_end()

	# Sort by modification time (newest first)
	saves.sort_custom(func(a, b): return a.modified_time > b.modified_time)

	return saves


func _collect_save_data() -> Dictionary:
	"""Collect save data from all managers"""
	var save_data = {
		"version": "1.0.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"game_version": "1.0.0"
	}

	# Collect data from managers
	if hot_dog_manager:
		var hot_dog_data = hot_dog_manager.get_save_data()
		save_data.merge(hot_dog_data)

	if customer_manager:
		var customer_data = customer_manager.get_save_data()
		save_data.merge(customer_data)

	if upgrade_manager:
		var upgrade_data = upgrade_manager.get_save_data()
		save_data.merge(upgrade_data)

	# Add event log data
	var event_log_manager = get_node_or_null("/root/EventLogManager")
	if event_log_manager:
		var event_log_data = event_log_manager.get_save_data()
		save_data.merge(event_log_data)

	# GameManager doesn't need to save data - it just manages scene transitions
	# All actual game data is stored in the other managers

	return save_data


func _apply_save_data(_save_data: Dictionary):
	"""Apply save data to all managers"""
	# Data will be applied through the save_data_loaded signal
	# which each manager listens to
	# Function kept for future expansion when direct data application is needed


func create_new_game():
	"""Create a new game by resetting all managers"""
	create_new_game_with_name("My Food Truck")


func create_new_game_with_name(truck_name: String):
	"""Create a new game with specific truck name"""
	print("SaveSystem: Creating new game with truck name: ", truck_name)

	# Reset all managers
	if hot_dog_manager:
		hot_dog_manager.reset_hot_dogs()

	if customer_manager:
		customer_manager.reset_customers()

	if upgrade_manager:
		upgrade_manager.reset_upgrades()

	if game_manager:
		game_manager.reset_game()

	# Set the truck name in the save data
	var save_data = _collect_save_data()
	save_data["truck_name"] = truck_name

	# Save the new game state with truck name
	_save_new_game_data(save_data)


func _save_new_game_data(save_data: Dictionary):
	"""Save new game data to autosave"""
	var file_path = save_directory + autosave_name + ".json"

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()

		print(
			"SaveSystem: New game saved with truck name: ", save_data.get("truck_name", "Unknown")
		)
		emit_signal("save_created", autosave_name)
	else:
		print("SaveSystem: Failed to save new game")


func migrate_old_save_data(old_data: Dictionary) -> Dictionary:
	"""Migrate old save data to new format"""
	var new_data = _collect_save_data()

	# Migrate currency data
	if old_data.has("currency"):
		var currency_data = old_data["currency"]
		if new_data.has("currency"):
			new_data["currency"]["balance"] = currency_data.get("balance", 0)
		if new_data.has("hot_dogs"):
			new_data["hot_dogs"]["total_currency_earned"] = currency_data.get("total_earned", 0)

	# Migrate click mechanics to hot dog production
	if old_data.has("click_value"):
		if new_data.has("hot_dogs"):
			new_data["hot_dogs"]["per_click"] = old_data["click_value"]

	# Migrate timing data
	if old_data.has("auto_clicker_speed"):
		if new_data.has("hot_dogs"):
			new_data["hot_dogs"]["production_rate"] = 0.3 / old_data["auto_clicker_speed"]

	# Migrate upgrades (map old to new)
	if old_data.has("upgrades_purchased"):
		# This would need more complex mapping logic
		pass

	return new_data
