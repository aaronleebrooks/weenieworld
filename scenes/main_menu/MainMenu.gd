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
	
	# Calculate responsive font size based on viewport
	var base_font_size = 24
	var responsive_font_size = max(base_font_size, int(viewport_size.x * 0.015))  # 1.5% of viewport width
	responsive_font_size = min(responsive_font_size, 48)  # Cap at 48px
	
	# Calculate responsive button size
	var button_height = max(50, int(viewport_size.y * 0.04))  # 4% of viewport height
	button_height = min(button_height, 80)  # Cap at 80px
	
	print("MainMenu: Responsive font size = ", responsive_font_size, ", button height = ", button_height)
	
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
		
		# Update button sizes and font sizes
		for button in [new_game_button, continue_button, options_button, quit_button]:
			button.custom_minimum_size = Vector2(0, button_height)
			button.add_theme_font_size_override("font_size", responsive_font_size)
		
		print("MainMenu: Menu container and buttons updated")
	
	# Adjust title position and font size
	if title:
		var title_width = min(viewport_size.x * 0.3, 300)
		title_width = max(title_width, 150)
		title.offset_left = -title_width / 2
		title.offset_right = title_width / 2
		title.add_theme_font_size_override("font_size", responsive_font_size + 8)  # Title slightly larger
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
