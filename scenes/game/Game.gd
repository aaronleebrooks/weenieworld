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
	
	# Use percentage-based sizing (like CSS vw/vh units)
	var font_size_percent = viewport_size.x * 0.025  # 2.5% of viewport width
	var button_height_percent = viewport_size.y * 0.08  # 8% of viewport height
	
	# Set reasonable bounds
	var responsive_font_size = max(16, min(font_size_percent, 64))  # 16px to 64px
	var button_height = max(40, min(button_height_percent, 120))  # 40px to 120px
	
	print("Game: Font size = ", responsive_font_size, "px (", font_size_percent, "px raw), Button height = ", button_height, "px (", button_height_percent, "px raw)")
	
	# Update hello world label font size
	if hello_world_label:
		hello_world_label.add_theme_font_size_override("font_size", responsive_font_size)
	
	# Update back button font size and size
	if back_button:
		back_button.custom_minimum_size = Vector2(0, button_height)
		back_button.add_theme_font_size_override("font_size", responsive_font_size)
		print("Game: Back button updated with percentage-based sizing")

func _on_back_button_pressed():
	print("Returning to main menu...")
	get_node("/root/GameManager").return_to_main_menu()

func display_game_data():
	# Show current currency and other game data
	var currency_manager = get_node("/root/CurrencyManager")
	if currency_manager:
		var currency = currency_manager.currency_balance
		var per_click = currency_manager.currency_per_click
		var click_rate = currency_manager.click_rate_seconds
		var idle_rate = currency_manager.idle_rate_seconds
		
		hello_world_label.text = "Hello World!\nCurrency: %d\nPer Click: %d\nClick Rate: %.2fs\nIdle Rate: %.2fs" % [currency, per_click, click_rate, idle_rate]
	else:
		hello_world_label.text = "Hello World!\nCurrencyManager not found"

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