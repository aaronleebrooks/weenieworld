extends Control

@onready var new_game_button = $MenuContainer/NewGameButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var options_button = $MenuContainer/OptionsButton
@onready var quit_button = $MenuContainer/QuitButton
@onready var menu_container = $MenuContainer
@onready var title = $Title

func _ready():
	print("MainMenu: _ready() called")
	
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect to viewport size changes using native event system
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial responsive sizing
	_update_responsive_layout()
	
	# Check if save file exists and enable/disable continue button
	update_continue_button()

func _on_viewport_size_changed():
	print("MainMenu: Viewport size changed")
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	print("MainMenu: Viewport size = ", viewport_size)
	
	# Adjust menu container size based on viewport
	var container_width = min(viewport_size.x * 0.4, 400)  # 40% of viewport or max 400px
	var container_height = min(viewport_size.y * 0.3, 300)  # 30% of viewport or max 300px
	
	# Ensure minimum size
	container_width = max(container_width, 200)
	container_height = max(container_height, 150)
	
	print("MainMenu: Container size = ", Vector2(container_width, container_height))
	
	if menu_container:
		menu_container.offset_left = -container_width / 2
		menu_container.offset_top = -container_height / 2
		menu_container.offset_right = container_width / 2
		menu_container.offset_bottom = container_height / 2
		print("MainMenu: Menu container updated")
	
	# Adjust title position
	if title:
		var title_width = min(viewport_size.x * 0.3, 300)
		title_width = max(title_width, 150)
		title.offset_left = -title_width / 2
		title.offset_right = title_width / 2
		print("MainMenu: Title updated")

func _on_new_game_pressed():
	print("Starting new game...")
	get_node("/root/GameManager").start_new_game()

func _on_continue_pressed():
	print("Opening save selection menu...")
	open_save_selection_menu()

func open_save_selection_menu():
	var save_menu_scene = preload("res://scenes/ui/SaveSelectionMenu.tscn")
	var save_menu = save_menu_scene.instantiate()
	add_child(save_menu)

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
		continue_button.text = "Load Game"
		continue_button.modulate = Color.WHITE
	else:
		continue_button.disabled = true
		continue_button.text = "No Save Data"
		continue_button.modulate = Color.GRAY 
