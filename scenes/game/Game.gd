extends Control

@onready var back_button = $BackButton
@onready var hello_world_label = $HelloWorldLabel

func _ready():
	print("Game: _ready() called")
	
	# Connect button signals
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Connect to viewport size changes using native event system
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial responsive sizing
	_update_responsive_layout()
	
	# Display current game data
	display_game_data()
	
	# Add manual save button for testing
	add_manual_save_button()

func _on_viewport_size_changed():
	print("Game: Viewport size changed")
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	print("Game: Viewport size = ", viewport_size)
	
	# Calculate responsive font size based on viewport
	var base_font_size = 24
	var responsive_font_size = max(base_font_size, int(viewport_size.x * 0.015))  # 1.5% of viewport width
	responsive_font_size = min(responsive_font_size, 48)  # Cap at 48px
	
	# Calculate responsive button size
	var button_height = max(50, int(viewport_size.y * 0.04))  # 4% of viewport height
	button_height = min(button_height, 80)  # Cap at 80px
	
	print("Game: Responsive font size = ", responsive_font_size, ", button height = ", button_height)
	
	# Update hello world label font size
	if hello_world_label:
		hello_world_label.add_theme_font_size_override("font_size", responsive_font_size)
	
	# Update back button font size and size
	if back_button:
		back_button.custom_minimum_size = Vector2(0, button_height)
		back_button.add_theme_font_size_override("font_size", responsive_font_size)
		print("Game: Back button updated")

func _on_back_button_pressed():
	print("Returning to main menu...")
	get_node("/root/GameManager").return_to_main_menu()

func display_game_data():
	# Show current currency and other game data
	var currency = get_node("/root/GameManager").get_game_data("currency", 0)
	var click_value = get_node("/root/GameManager").get_game_data("click_value", 1)
	
	hello_world_label.text = "Hello World!\nCurrency: %d\nClick Value: %d" % [currency, click_value]

func add_manual_save_button():
	var save_button = Button.new()
	save_button.text = "Manual Save"
	save_button.position = Vector2(20, 100)
	save_button.pressed.connect(_on_manual_save_pressed)
	add_child(save_button)

func _on_manual_save_pressed():
	print("Creating manual save...")
	var success = get_node("/root/SaveSystem").create_manual_save()
	if success:
		print("Manual save created successfully!")
	else:
		print("Failed to create manual save!")

func _input(event):
	# Handle escape key to return to menu
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed() 