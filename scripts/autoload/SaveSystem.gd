extends Node

const SAVE_DIR = "user://saves/"
const AUTO_SAVE_FILE = "autosave.json"
const MANUAL_SAVE_PREFIX = "manual_save_"
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
	# Try to load autosave first
	var autosave_path = SAVE_DIR + AUTO_SAVE_FILE
	var file = FileAccess.open(autosave_path, FileAccess.READ)
	if file == null:
		# No save file exists, just return default data without saving
		current_save_data = get_default_save_data()
		return current_save_data
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Failed to parse save file, creating new save data")
		current_save_data = get_default_save_data()
		return current_save_data
	
	current_save_data = json.data
	emit_signal("save_data_loaded", current_save_data)
	return current_save_data

# Save current data to file (autosave)
func save_game() -> bool:
	current_save_data["last_save_time"] = Time.get_datetime_string_from_system()
	current_save_data["save_type"] = "autosave"
	
	# Ensure save directory exists
	ensure_save_directory()
	
	var autosave_path = SAVE_DIR + AUTO_SAVE_FILE
	var file = FileAccess.open(autosave_path, FileAccess.WRITE)
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

# Ensure save directory exists
func ensure_save_directory():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

# Check if any save file exists
func has_save_file() -> bool:
	var autosave_path = SAVE_DIR + AUTO_SAVE_FILE
	if FileAccess.file_exists(autosave_path):
		return true
	
	# Check for manual saves
	var dir = DirAccess.open(SAVE_DIR)
	if dir == null:
		return false
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with(MANUAL_SAVE_PREFIX) and file_name.ends_with(".json"):
			return true
		file_name = dir.get_next()
	
	return false

# Get list of available save files
func get_save_files() -> Array:
	var saves = []
	print("Getting save files...")
	
	# Check autosave
	var autosave_path = SAVE_DIR + AUTO_SAVE_FILE
	print("Checking autosave path: ", autosave_path)
	if FileAccess.file_exists(autosave_path):
		print("Autosave exists")
		var autosave_data = load_save_file(autosave_path)
		if autosave_data.has("last_save_time"):
			saves.append({
				"name": "Autosave",
				"path": autosave_path,
				"time": autosave_data["last_save_time"],
				"type": "autosave"
			})
			print("Added autosave to list")
	else:
		print("Autosave does not exist")
	
	# Check manual saves
	var dir = DirAccess.open(SAVE_DIR)
	if dir != null:
		print("Opened saves directory")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var manual_save_count = 0
		
		while file_name != "" and manual_save_count < 3:
			print("Checking file: ", file_name)
			if file_name.begins_with(MANUAL_SAVE_PREFIX) and file_name.ends_with(".json"):
				var save_path = SAVE_DIR + file_name
				print("Found manual save: ", save_path)
				var save_data = load_save_file(save_path)
				if save_data.has("last_save_time"):
					saves.append({
						"name": "Manual Save " + str(manual_save_count + 1),
						"path": save_path,
						"time": save_data["last_save_time"],
						"type": "manual"
					})
					manual_save_count += 1
					print("Added manual save to list")
			file_name = dir.get_next()
	else:
		print("Failed to open saves directory")
	
	print("Total saves found: ", saves.size())
	return saves

# Load a specific save file
func load_save_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	return json.data

# Load a specific save
func load_specific_save(save_info: Dictionary) -> Dictionary:
	if save_info.has("path"):
		current_save_data = load_save_file(save_info["path"])
		if current_save_data.is_empty():
			current_save_data = get_default_save_data()
		return current_save_data
	return get_default_save_data()

# Create manual save
func create_manual_save() -> bool:
	current_save_data["last_save_time"] = Time.get_datetime_string_from_system()
	current_save_data["save_type"] = "manual"
	
	ensure_save_directory()
	
	# Find next available slot
	var slot_number = 1
	while slot_number <= 3:
		var save_path = SAVE_DIR + MANUAL_SAVE_PREFIX + str(slot_number) + ".json"
		if not FileAccess.file_exists(save_path):
			break
		slot_number += 1
	
	if slot_number > 3:
		# Replace oldest manual save
		slot_number = 1
	
	var save_path = SAVE_DIR + MANUAL_SAVE_PREFIX + str(slot_number) + ".json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	
	var json_string = JSON.stringify(current_save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	return true

# Delete a specific save file
func delete_save_file(save_info: Dictionary) -> bool:
	if not save_info.has("path"):
		print("No path in save_info")
		return false
	
	var file_path = save_info["path"]
	print("Attempting to delete: ", file_path)
	
	if not FileAccess.file_exists(file_path):
		print("File does not exist: ", file_path)
		return false
	
	# Try using DirAccess to the saves directory directly
	var saves_dir = DirAccess.open("user://saves")
	if saves_dir == null:
		print("Failed to open saves directory")
		return false
	
	# Extract filename from path
	var filename = file_path.get_file()
	print("Removing file: ", filename)
	
	var result = saves_dir.remove(filename)
	print("Delete result: ", result)
	
	# Verify deletion
	if result:
		if not FileAccess.file_exists(file_path):
			print("File successfully deleted")
		else:
			print("File still exists after deletion!")
			return false
	else:
		print("Delete operation failed")
	
	return result 