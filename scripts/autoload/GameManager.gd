extends Node

# Game state management for hot dog store idle game
# Uses intentional naming conventions for future maintainability

const DEBUG_MODE: bool = false

# Scene paths
const MAIN_MENU_SCENE = "res://scenes/main_menu/MainMenu.tscn"
const GAME_SCENE = "res://scenes/game/Game.tscn"

# Signals
signal game_started
signal game_paused
signal game_resumed
signal scene_changed(scene_name: String)

# Game state
var is_game_active: bool = false
var current_scene: String = ""

# References to managers
var save_system: Node
var hot_dog_manager: Node
var customer_manager: Node
var upgrade_manager: Node


func _ready():
	if DEBUG_MODE:
		print("GameManager: Initialized")

	# Get references to managers
	save_system = get_node_or_null("/root/SaveSystem")
	hot_dog_manager = get_node_or_null("/root/HotDogManager")
	customer_manager = get_node_or_null("/root/CustomerManager")
	upgrade_manager = get_node_or_null("/root/UpgradeManager")

	# Validate critical dependencies
	if not save_system:
		push_error("GameManager: SaveSystem not found!")
	if not hot_dog_manager:
		push_error("GameManager: HotDogManager not found!")

	# Connect to save system
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)


# Start a new game
func start_new_game():
	print("GameManager: Starting new game with default truck name")
	start_new_game_with_name("My Food Truck")


# Start a new game with specific truck name
func start_new_game_with_name(truck_name: String):
	print("GameManager: Starting new game with truck name: ", truck_name)

	# Reset animation system first
	var animation_manager = get_node_or_null("/root/AnimationManager")
	if animation_manager:
		animation_manager.reset_animations()

	# Create new game by resetting all managers
	if save_system:
		save_system.create_new_game_with_name(truck_name)

	is_game_active = true
	change_scene(GAME_SCENE)
	emit_signal("game_started")


# Continue existing game
func continue_game():
	print("GameManager: Continuing existing game")

	# Try to load autosave
	if save_system:
		var save_list = save_system.get_save_list()
		if save_list.size() > 0:
			# Load the most recent save (autosave or manual save)
			var latest_save = save_list[0]
			if save_system.load_game(latest_save["name"]):
				is_game_active = true
				change_scene(GAME_SCENE)
				emit_signal("game_started")
				return

	# If no save found, start new game
	print("GameManager: No save found, starting new game")
	start_new_game()


# Change scene
func change_scene(scene_path: String):
	"""Change to a new scene"""
	current_scene = scene_path
	get_tree().change_scene_to_file(scene_path)
	emit_signal("scene_changed", scene_path)
	print("GameManager: Changed scene to ", scene_path)


# Return to main menu
func return_to_main_menu():
	"""Return to main menu, saving current game"""
	print("GameManager: Returning to main menu")

	# Save current game before leaving
	if save_system and is_game_active:
		save_system.save_game("autosave")

	# Reset animation system to clean up any existing squares
	var animation_manager = get_node_or_null("/root/AnimationManager")
	if animation_manager:
		animation_manager.reset_animations()

	is_game_active = false
	change_scene(MAIN_MENU_SCENE)


# Quit game
func quit_game():
	"""Quit the game, saving current progress"""
	print("GameManager: Quitting game")

	# Save before quitting
	if save_system and is_game_active:
		save_system.save_game("autosave")

	get_tree().quit()


# Pause game
func pause_game():
	"""Pause the game"""
	print("GameManager: Pausing game")
	emit_signal("game_paused")

	# Pause customer purchases
	if customer_manager:
		customer_manager.pause_customers()


# Resume game
func resume_game():
	"""Resume the game"""
	print("GameManager: Resuming game")
	emit_signal("game_resumed")

	# Resume customer purchases
	if customer_manager:
		customer_manager.resume_customers()


# Check if game is active
func get_game_active() -> bool:
	"""Check if a game is currently active"""
	return is_game_active


# Reset game
func reset_game():
	"""Reset all game data to starting values"""
	print("GameManager: Resetting game")

	if hot_dog_manager:
		hot_dog_manager.reset_hot_dogs()

	if customer_manager:
		customer_manager.reset_customers()

	if upgrade_manager:
		upgrade_manager.reset_upgrades()

	is_game_active = false


# Load a specific save
func load_specific_save(save_name: String):
	"""Load a specific save file"""
	print("GameManager: Loading specific save: ", save_name)

	if save_system:
		if save_system.load_game(save_name):
			is_game_active = true
			change_scene(GAME_SCENE)
			emit_signal("game_started")


# Handle save data loaded
func _on_save_data_loaded(_data: Dictionary):
	"""Handle save data loaded from SaveSystem"""
	print("GameManager: Save data loaded")
	is_game_active = true
