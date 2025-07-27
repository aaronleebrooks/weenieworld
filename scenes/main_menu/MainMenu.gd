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
	
	# Use percentage-based font sizing (like CSS vw/vh units)
	var font_size_percent = viewport_size.x * 0.025  # 2.5% of viewport width (like CSS vw)
	var button_height_percent = viewport_size.y * 0.08  # 8% of viewport height (like CSS vh)
	
	# Set reasonable bounds
	var responsive_font_size = max(16, min(font_size_percent, 64))  # 16px to 64px
	var button_height = max(40, min(button_height_percent, 120))  # 40px to 120px
	
	print("MainMenu: Font size = ", responsive_font_size, "px (", font_size_percent, "px raw), Button height = ", button_height, "px (", button_height_percent, "px raw)")
	
	# Update button sizes and font sizes using percentage-based approach
	for button in [new_game_button, continue_button, options_button, quit_button]:
		button.custom_minimum_size = Vector2(0, button_height)
		button.add_theme_font_size_override("font_size", responsive_font_size)
		# Add some padding like CSS
		button.add_theme_constant_override("h_separation", int(button_height * 0.1))
	
	# Update title font size
	if title:
		title.add_theme_font_size_override("font_size", responsive_font_size * 1.5)  # Title 50% larger
		print("MainMenu: Title font size = ", responsive_font_size * 1.5)
	
	print("MainMenu: All elements updated with percentage-based sizing")

func _on_new_game_pressed():
	print("Starting new game...")
	get_node("/root/GameManager").start_new_game()

func _on_continue_pressed():
	print("Continuing existing game...")
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
	"""Check if save files exist and update continue button"""
	var save_system = get_node("/root/SaveSystem")
	if not save_system:
		print("MainMenu: SaveSystem not found")
		_handle_no_save()
		return
	
	var save_list = save_system.get_save_list()
	var has_save = save_list.size() > 0
	print("MainMenu: Save files found: ", save_list.size())
	
	if has_save:
		continue_button.disabled = false
		continue_button.text = "Continue Game"
		continue_button.modulate = Color.WHITE
	else:
		_handle_no_save()

func _handle_no_save():
	"""Handle case when no save files exist"""
	continue_button.disabled = true
	continue_button.text = "No Save Data"
	continue_button.modulate = Color.GRAY 
