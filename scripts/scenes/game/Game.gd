extends Control

# Main game scene for hot dog store idle game
# Uses intentional naming conventions for future maintainability

const DEBUG_MODE: bool = false

@onready var truck_name_display = $TruckNameDisplay
@onready var menu_toggle_button = $TopLeftMenu/MenuToggleButton
@onready var menu_buttons_container = $TopLeftMenu/MenuButtonsContainer
@onready var currency_button = $TopLeftMenu/MenuButtonsContainer/CurrencyButton
@onready var upgrade_button = $TopLeftMenu/MenuButtonsContainer/UpgradeButton
@onready var save_button = $TopLeftMenu/MenuButtonsContainer/SaveButton
@onready var exit_button = $TopLeftMenu/MenuButtonsContainer/ExitButton

@onready var hot_dog_display = $HotDogDisplay
@onready var currency_display = $CurrencyDisplay
@onready var upgrade_panel = $UpgradePanel
@onready var event_log = $EventLog

# References to managers
var hot_dog_manager: Node
var customer_manager: Node
var upgrade_manager: Node
var save_system: Node
var floating_text_manager: Node
var event_log_manager: Node

# Menu state
var menu_expanded: bool = true  # true = full mode, false = icon mode


func _ready():
	if DEBUG_MODE:
		print("Game: _ready() called")

	# Get references to managers
	hot_dog_manager = get_node("/root/HotDogManager")
	customer_manager = get_node("/root/CustomerManager")
	upgrade_manager = get_node("/root/UpgradeManager")
	save_system = get_node("/root/SaveSystem")
	floating_text_manager = get_node("/root/FloatingTextManager")
	event_log_manager = get_node("/root/EventLogManager")

	# Connect button signals
	menu_toggle_button.pressed.connect(_on_menu_toggle_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	# Setup menu buttons
	_setup_menu_buttons()

	# Set initial menu state
	_update_menu_display()

	# Connect to viewport size changes using native event system
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	# Connect to hot dog changes to update display
	if hot_dog_manager:
		hot_dog_manager.hot_dogs_changed.connect(_on_hot_dogs_changed)
		hot_dog_manager.hot_dogs_produced.connect(_on_hot_dogs_produced)
		hot_dog_manager.hot_dogs_sold.connect(_on_hot_dogs_sold)
		hot_dog_manager.currency_changed.connect(_on_currency_changed)
		hot_dog_manager.currency_earned.connect(_on_currency_earned)
		hot_dog_manager.currency_spent.connect(_on_currency_spent)

	# Connect to customer manager
	if customer_manager:
		customer_manager.customer_purchase.connect(_on_customer_purchase)
		customer_manager.customer_arrived.connect(_on_customer_arrived)

	# Connect to click manager for hot dog production events
	var click_manager = get_node("/root/ClickManager")
	if click_manager:
		click_manager.click_completed.connect(_on_click_completed)

	# Initial responsive sizing
	_update_responsive_layout()

	# Display current game data
	display_game_data()

	# Load and display truck name
	_load_and_display_truck_name()

	# Create animation squares
	var animation_manager = get_node("/root/AnimationManager")
	if animation_manager:
		animation_manager._create_central_animation_squares()

	# Debug: Verify all UI elements are properly connected
	_debug_verify_ui_elements()


func _exit_tree():
	"""Clean up when leaving the game scene"""
	print("Game: Cleaning up game scene")
	_cleanup_game_scene()


func _cleanup_game_scene():
	"""Clean up all game scene resources and connections"""
	print("Game: Starting game scene cleanup")

	# Disconnect all signals to prevent memory leaks
	if hot_dog_manager:
		if hot_dog_manager.hot_dogs_changed.is_connected(_on_hot_dogs_changed):
			hot_dog_manager.hot_dogs_changed.disconnect(_on_hot_dogs_changed)
		if hot_dog_manager.hot_dogs_produced.is_connected(_on_hot_dogs_produced):
			hot_dog_manager.hot_dogs_produced.disconnect(_on_hot_dogs_produced)
		if hot_dog_manager.hot_dogs_sold.is_connected(_on_hot_dogs_sold):
			hot_dog_manager.hot_dogs_sold.disconnect(_on_hot_dogs_sold)
		if hot_dog_manager.currency_changed.is_connected(_on_currency_changed):
			hot_dog_manager.currency_changed.disconnect(_on_currency_changed)
		if hot_dog_manager.currency_earned.is_connected(_on_currency_earned):
			hot_dog_manager.currency_earned.disconnect(_on_currency_earned)
		if hot_dog_manager.currency_spent.is_connected(_on_currency_spent):
			hot_dog_manager.currency_spent.disconnect(_on_currency_spent)

	if customer_manager:
		if customer_manager.customer_purchase.is_connected(_on_customer_purchase):
			customer_manager.customer_purchase.disconnect(_on_customer_purchase)
		if customer_manager.customer_arrived.is_connected(_on_customer_arrived):
			customer_manager.customer_arrived.disconnect(_on_customer_arrived)

	var click_manager = get_node_or_null("/root/ClickManager")
	if click_manager and click_manager.click_completed.is_connected(_on_click_completed):
		click_manager.click_completed.disconnect(_on_click_completed)

	# Disconnect viewport size changes
	if get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.disconnect(_on_viewport_size_changed)

	# Clean up animation squares
	var animation_manager = get_node_or_null("/root/AnimationManager")
	if animation_manager:
		animation_manager.reset_animations()

	print("Game: Game scene cleanup completed")


func _debug_verify_ui_elements():
	"""Debug function to verify all UI elements are properly connected"""
	print("\n=== GAME SCENE UI AUDIT ===")

	# Check main UI elements
	print("Checking main UI elements...")
	_debug_check_node("TruckNameDisplay", truck_name_display)
	_debug_check_node("CurrencyDisplay", currency_display)
	_debug_check_node("HotDogDisplay", hot_dog_display)
	_debug_check_node("ProgressBar", get_node_or_null("ProgressBar"))
	_debug_check_node("CurrencyGainButton", get_node_or_null("CurrencyGainButton"))
	_debug_check_node("UpgradePanel", upgrade_panel)

	# Check top-left menu elements
	print("\nChecking top-left menu elements...")
	_debug_check_node("MenuToggleButton", menu_toggle_button)
	_debug_check_node("CurrencyButton", currency_button)
	_debug_check_node("UpgradeButton", upgrade_button)
	_debug_check_node("SaveButton", save_button)
	_debug_check_node("ExitButton", exit_button)

	# Check manager connections
	print("\nChecking manager connections...")
	_debug_check_manager("HotDogManager", hot_dog_manager)
	_debug_check_manager("CustomerManager", customer_manager)
	_debug_check_manager("UpgradeManager", upgrade_manager)
	_debug_check_manager("SaveSystem", save_system)
	_debug_check_manager("FloatingTextManager", floating_text_manager)

	# Check FloatingText system specifically
	print("\nChecking FloatingText system...")
	var floating_text_manager = get_node_or_null("/root/FloatingTextManager")
	if floating_text_manager:
		print("✓ FloatingTextManager found")
		print("  - Pool size: %d" % floating_text_manager.floating_text_pool.size())
		print("  - Active texts: %d" % floating_text_manager.active_floating_texts.size())
	else:
		print("✗ FloatingTextManager NOT FOUND")

	# Check if FloatingText scene exists
	var floating_text_scene = preload("res://scenes/ui/FloatingText.tscn")
	if floating_text_scene:
		print("✓ FloatingText scene can be loaded")
	else:
		print("✗ FloatingText scene cannot be loaded")

	print("=== END UI AUDIT ===\n")


func _debug_check_node(node_name: String, node: Node):
	"""Debug helper to check if a node exists and is valid"""
	if node and is_instance_valid(node):
		print("✓ %s: Found and valid" % node_name)
		if node.has_method("get_text"):
			print("  - Text: '%s'" % node.text)
		elif node.has_method("get_tooltip_text"):
			print("  - Tooltip: '%s'" % node.tooltip_text)
	else:
		print("✗ %s: NOT FOUND or INVALID" % node_name)


func _debug_check_manager(manager_name: String, manager: Node):
	"""Debug helper to check if a manager exists and is valid"""
	if manager and is_instance_valid(manager):
		print("✓ %s: Found and valid" % manager_name)
	else:
		print("✗ %s: NOT FOUND or INVALID" % manager_name)


func _setup_menu_buttons():
	"""Setup initial menu button configuration"""
	# Set up tooltips for icon mode
	if currency_button:
		currency_button.tooltip_text = "Currency and Hot Dog Balance"
	if upgrade_button:
		upgrade_button.tooltip_text = "Upgrades"
	if save_button:
		save_button.tooltip_text = "Save Game"
	if exit_button:
		exit_button.tooltip_text = "Exit to Main Menu"


func _update_menu_display():
	"""Update entire menu display based on current state"""
	_update_menu_button_texts()
	_update_currency_button_display()


func _update_menu_button_texts():
	"""Update button texts and sizes based on menu state"""
	if menu_expanded:
		# Full mode: wide buttons with labels
		if currency_button:
			currency_button.custom_minimum_size.x = 0  # Auto-size
		if upgrade_button:
			upgrade_button.text = "⚡ Upgrades"
			upgrade_button.custom_minimum_size.x = 0
		if save_button:
			save_button.text = "💾 Save"
			save_button.custom_minimum_size.x = 0
		if exit_button:
			exit_button.text = "🚪 Exit"
			exit_button.custom_minimum_size.x = 0
	else:
		# Icon mode: narrow buttons with icons only
		if currency_button:
			currency_button.custom_minimum_size.x = 40  # Very narrow
		if upgrade_button:
			upgrade_button.text = "⚡"
			upgrade_button.custom_minimum_size.x = 40
		if save_button:
			save_button.text = "💾"
			save_button.custom_minimum_size.x = 40
		if exit_button:
			exit_button.text = "🚪"
			exit_button.custom_minimum_size.x = 40


func _on_viewport_size_changed():
	"""Handle viewport size changes for responsive design"""
	_update_responsive_layout()


func _update_responsive_layout():
	"""Update layout for responsive design"""
	var viewport_size = get_viewport().get_visible_rect().size

	print("Game: Responsive layout updated for viewport size: ", viewport_size)


func _load_and_display_truck_name():
	"""Load and display the truck name from save data"""
	if save_system:
		var save_list = save_system.get_save_list()
		if save_list.size() > 0:
			# Load the most recent save to get truck name
			var latest_save = save_list[0]
			var file_path = save_system.save_directory + latest_save["name"] + ".json"

			if FileAccess.file_exists(file_path):
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var json_string = file.get_as_text()
					file.close()

					var json = JSON.new()
					var parse_result = json.parse(json_string)

					if parse_result == OK:
						var save_data = json.data
						var truck_name = save_data.get("truck_name", "My Food Truck")
						_display_truck_name(truck_name)
						print("Game: Loaded truck name: ", truck_name)
					else:
						_display_truck_name("My Food Truck")
				else:
					_display_truck_name("My Food Truck")
			else:
				_display_truck_name("My Food Truck")
		else:
			_display_truck_name("My Food Truck")
	else:
		_display_truck_name("My Food Truck")


func _display_truck_name(truck_name: String):
	"""Display the truck name in the UI"""
	if truck_name_display:
		truck_name_display.text = truck_name
		print("Game: Displaying truck name: ", truck_name)


func _on_hot_dogs_changed(new_inventory: int, change_amount: int):
	"""Handle hot dog inventory changes"""
	_update_currency_button_display()


func _on_hot_dogs_produced(amount: int, source: String):
	"""Handle hot dog production events"""
	# Show floating text for hot dog gain
	if floating_text_manager and hot_dog_display:
		floating_text_manager.show_hot_dog_gain(amount, hot_dog_display)


func _on_hot_dogs_sold(amount: int, value: int):
	"""Handle hot dog sales events"""


func _on_currency_changed(new_balance: int, change_amount: int):
	"""Handle currency balance changes"""
	_update_currency_button_display()


func _on_currency_earned(amount: int, source: String):
	"""Handle currency earned events"""
	# Show floating text for currency gain
	if floating_text_manager and currency_display:
		floating_text_manager.show_currency_gain(amount, currency_display)


func _on_currency_spent(amount: int, reason: String):
	"""Handle currency spent events"""


func _on_customer_purchase(amount: int, value: int):
	"""Handle customer purchase events"""


func _on_customer_arrived():
	"""Handle customer arrival events"""


func _on_click_completed(click_type: String, hot_dogs_produced: int):
	"""Handle click completion events"""


func _on_menu_toggle_pressed():
	"""Handle menu toggle button press"""
	print("Game: Menu toggle pressed")
	menu_expanded = !menu_expanded

	# Update toggle button text
	if menu_toggle_button:
		menu_toggle_button.text = "<" if menu_expanded else ">"

	# Update menu display
	_update_menu_display()


func _on_upgrade_button_pressed():
	"""Handle upgrade button press"""
	print("Game: Upgrade button pressed")
	if upgrade_panel:
		upgrade_panel.visible = !upgrade_panel.visible


func _on_save_button_pressed():
	"""Handle save button press"""
	print("Game: Save button pressed")
	if save_system:
		save_system.save_game("autosave")
		# Add save event to event log
		if event_log_manager:
			event_log_manager.add_save_event("manual")


func _on_exit_button_pressed():
	"""Handle exit button press"""
	print("Game: Exit button pressed")
	_show_exit_confirmation_modal()


func _show_exit_confirmation_modal():
	"""Show the exit confirmation modal"""
	var modal_scene = preload("res://scenes/ui/ExitConfirmationModal.tscn")
	var modal = modal_scene.instantiate()
	add_child(modal)

	# Connect modal signals
	modal.exit_confirmed.connect(_on_exit_confirmed)
	modal.exit_cancelled.connect(_on_exit_cancelled)


func _on_exit_confirmed():
	"""Handle exit confirmation"""
	print("Game: Exit confirmed, returning to main menu")
	# Return to main menu using GameManager for proper cleanup
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.return_to_main_menu()
	else:
		# Fallback if GameManager not available
		get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")


func _on_exit_cancelled():
	"""Handle exit cancellation"""
	print("Game: Exit cancelled, staying in game")


func _update_currency_button_display():
	"""Update currency button with current values"""
	if currency_button and hot_dog_manager:
		var currency = hot_dog_manager.currency_balance
		var hot_dogs = hot_dog_manager.hot_dogs_inventory

		if not menu_expanded:
			currency_button.text = "💰"
			currency_button.tooltip_text = "Currency: %d\nHot Dogs: %d" % [currency, hot_dogs]
		else:
			currency_button.text = "💰 Currency: %d | Hot Dogs: %d" % [currency, hot_dogs]
			currency_button.tooltip_text = "Current balances"


func display_game_data():
	"""Display current game data for debugging"""
	if DEBUG_MODE:
		print("Game: Displaying current game data")

	if hot_dog_manager:
		print(
			(
				"  Hot Dogs: %d (per click: %d)"
				% [hot_dog_manager.hot_dogs_inventory, hot_dog_manager.hot_dogs_per_click]
			)
		)
		print(
			(
				"  Currency: %d (sale value: %d)"
				% [hot_dog_manager.currency_balance, hot_dog_manager.sale_value]
			)
		)
		print("  Production Rate: %.2fs" % hot_dog_manager.production_rate_seconds)
		print("  Idle Rate: %.2fs" % hot_dog_manager.idle_rate_seconds)

	if customer_manager:
		print("  Customer Purchase Rate: %.2fs" % customer_manager.get_purchase_rate())
		print("  Customers per minute: %.1f" % customer_manager.get_customers_per_minute())

	# Update displays
	_update_currency_button_display()
