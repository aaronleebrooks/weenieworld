extends Control

@onready var new_game_button = $MenuContainer/NewGameButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var options_button = $MenuContainer/OptionsButton
@onready var quit_button = $MenuContainer/QuitButton

func _ready():
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Check if save file exists and enable/disable continue button
	update_continue_button()

func _on_new_game_pressed():
	print("Starting new game...")
	get_node("/root/GameManager").start_new_game()

func _on_continue_pressed():
	print("Continuing game...")
	get_node("/root/GameManager").continue_game()

func _on_options_pressed():
	print("Opening options...")
	# TODO: Implement options menu
	# For now, just show a message
	print("Options menu not implemented yet")

func _on_quit_pressed():
	print("Quitting game...")
	get_node("/root/GameManager").quit_game()

func update_continue_button():
	# Check if save file exists and update continue button
	var has_save = get_node("/root/SaveSystem").has_save_file()
	print("Save file exists: ", has_save)
	
	if has_save:
		continue_button.disabled = false
		continue_button.text = "Continue"
		continue_button.modulate = Color.WHITE
	else:
		continue_button.disabled = true
		continue_button.text = "No Save Data"
		continue_button.modulate = Color.GRAY 
