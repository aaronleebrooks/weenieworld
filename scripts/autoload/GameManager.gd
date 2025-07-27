extends Node

# Game state
var current_scene: Node
var game_data: Dictionary

# Scene paths
const MAIN_MENU_SCENE = "res://scenes/main_menu/MainMenu.tscn"
const GAME_SCENE = "res://scenes/game/Game.tscn"

# Signals
signal game_started()
signal game_paused()
signal game_resumed()
signal scene_changed(scene_name: String)

func _ready():
	# Load initial save data
	game_data = get_node("/root/SaveSystem").get_save_data()
	
	# Set up scene change handling
	get_tree().current_scene_changed.connect(_on_scene_changed)

# Start a new game
func start_new_game():
	game_data = get_node("/root/SaveSystem").new_game()
	change_scene(GAME_SCENE)
	emit_signal("game_started")

# Continue existing game
func continue_game():
	if get_node("/root/SaveSystem").has_save_file():
		game_data = get_node("/root/SaveSystem").get_save_data()
		change_scene(GAME_SCENE)
		emit_signal("game_started")
	else:
		print("No save file found")

# Change scene
func change_scene(scene_path: String):
	# Save current game state if in game scene
	if current_scene and current_scene.scene_file_path == GAME_SCENE:
		get_node("/root/SaveSystem").save_game()
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)

# Return to main menu
func return_to_main_menu():
	change_scene(MAIN_MENU_SCENE)

# Quit game
func quit_game():
	# Save before quitting
	if current_scene and current_scene.scene_file_path == GAME_SCENE:
		get_node("/root/SaveSystem").save_game()
	get_tree().quit()

# Update game data
func update_game_data(key: String, value):
	game_data[key] = value
	get_node("/root/SaveSystem").update_save_data(key, value)

# Get game data
func get_game_data(key: String, default_value = null):
	return game_data.get(key, default_value)

# Handle scene changes
func _on_scene_changed():
	current_scene = get_tree().current_scene
	if current_scene:
		emit_signal("scene_changed", current_scene.scene_file_path)

# Handle save data loaded
func _on_save_data_loaded(data: Dictionary):
	game_data = data
	print("Save data loaded: ", data) 