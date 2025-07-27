extends Node

const SAVE_FILE_PATH = "user://weenieworld_save.json"
const AUTO_SAVE_INTERVAL = 30.0  # seconds

var current_save_data: Dictionary
var auto_save_timer: float = 0.0
var has_unsaved_changes: bool = false

signal save_data_loaded(data: Dictionary)
signal save_data_saved(data: Dictionary)

func _init():
	load_save_data()

func _process(delta: float):
	if has_unsaved_changes:
		auto_save_timer += delta
		if auto_save_timer >= AUTO_SAVE_INTERVAL:
			save_game()
			auto_save_timer = 0.0

# Get default save data
func get_default_save_data() -> Dictionary:
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

# Load save data from file
func load_save_data() -> Dictionary:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		# No save file exists, create default data
		current_save_data = get_default_save_data()
		save_game()
		return current_save_data
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Failed to parse save file, creating new save data")
		current_save_data = get_default_save_data()
		save_game()
		return current_save_data
	
	current_save_data = json.data
	emit_signal("save_data_loaded", current_save_data)
	return current_save_data

# Save current data to file
func save_game() -> bool:
	current_save_data["last_save_time"] = Time.get_datetime_string_from_system()
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file for writing")
		return false
	
	var json_string = JSON.stringify(current_save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	has_unsaved_changes = false
	emit_signal("save_data_saved", current_save_data)
	return true

# Create new game (reset save data)
func new_game() -> Dictionary:
	current_save_data = get_default_save_data()
	save_game()
	return current_save_data

# Get current save data
func get_save_data() -> Dictionary:
	return current_save_data

# Update save data
func update_save_data(key: String, value) -> void:
	current_save_data[key] = value
	has_unsaved_changes = true

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

# Delete save file
func delete_save_file() -> bool:
	if has_save_file():
		var dir = DirAccess.open("user://")
		return dir.remove("weenieworld_save.json")
	return false 