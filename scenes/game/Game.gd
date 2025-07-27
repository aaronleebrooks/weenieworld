extends Control

# Main game scene for hot dog store idle game
# Uses intentional naming conventions for future maintainability

@onready var currency_icon = $TopLeftMenu/CurrencyIcon
@onready var upgrade_icon = $TopLeftMenu/UpgradeIcon
@onready var save_icon = $TopLeftMenu/SaveIcon
@onready var exit_icon = $TopLeftMenu/ExitIcon
@onready var hot_dog_display = $HotDogDisplay
@onready var currency_display = $CurrencyDisplay
@onready var upgrade_panel = $UpgradePanel

# References to managers
var hot_dog_manager: Node
var customer_manager: Node
var upgrade_manager: Node
var save_system: Node
var floating_text_manager: Node

# Tooltip toggle state
var tooltips_visible: bool = true

func _ready():
	print("Game: _ready() called")
	
	# Get references to managers
	hot_dog_manager = get_node("/root/HotDogManager")
	customer_manager = get_node("/root/CustomerManager")
	upgrade_manager = get_node("/root/UpgradeManager")
	save_system = get_node("/root/SaveSystem")
	floating_text_manager = get_node("/root/FloatingTextManager")
	
	# Create tooltip toggle button
	_create_tooltip_toggle()
	
	# Connect button signals
	upgrade_icon.pressed.connect(_on_upgrade_icon_pressed)
	save_icon.pressed.connect(_on_save_icon_pressed)
	exit_icon.pressed.connect(_on_exit_icon_pressed)
	
	# Setup currency icon (non-clickable, blue text)
	_setup_currency_icon()
	
	# Setup tooltips for icons
	_setup_tooltips()
	
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
	
	# Create animation squares
	var animation_manager = get_node("/root/AnimationManager")
	if animation_manager:
		animation_manager._create_central_animation_squares()
		# Make sure squares are visible
		animation_manager.make_squares_visible()

func _create_tooltip_toggle():
	"""Create tooltip toggle button"""
	var toggle_button = Button.new()
	toggle_button.text = "Toggle Labels"
	toggle_button.custom_minimum_size = Vector2(100, 30)
	toggle_button.pressed.connect(_on_tooltip_toggle_pressed)
	
	# Position in top-right corner
	toggle_button.position = Vector2(get_viewport().get_visible_rect().size.x - 120, 10)
	add_child(toggle_button)

func _setup_currency_icon():
	"""Setup currency icon display"""
	if currency_icon:
		currency_icon.text = "💰"
		currency_icon.add_theme_font_size_override("font_size", 24)

func _setup_tooltips():
	"""Setup tooltips for UI icons"""
	if upgrade_icon:
		upgrade_icon.tooltip_text = "Upgrades"
	if save_icon:
		save_icon.tooltip_text = "Save Game"
	if exit_icon:
		exit_icon.tooltip_text = "Exit to Menu"

func _on_viewport_size_changed():
	"""Handle viewport size changes for responsive design"""
	_update_responsive_layout()

func _update_responsive_layout():
	"""Update layout for responsive design"""
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Update tooltip toggle position
	var toggle_button = get_node_or_null("Button")  # The tooltip toggle button
	if toggle_button:
		toggle_button.position = Vector2(viewport_size.x - 120, 10)
	
	print("Game: Responsive layout updated for viewport size: ", viewport_size)

func _on_tooltip_toggle_pressed():
	"""Toggle tooltip visibility"""
	tooltips_visible = !tooltips_visible
	
	# Update icon labels
	if currency_icon:
		currency_icon.text = "💰" if tooltips_visible else ""
	if upgrade_icon:
		upgrade_icon.text = "⚡" if tooltips_visible else ""
	if save_icon:
		save_icon.text = "💾" if tooltips_visible else ""
	if exit_icon:
		exit_icon.text = "❌" if tooltips_visible else ""
	
	print("Game: Tooltips toggled - visible: ", tooltips_visible)

func _on_hot_dogs_changed(new_inventory: int, change_amount: int):
	"""Handle hot dog inventory changes"""
	_update_currency_icon_display()

func _on_hot_dogs_produced(amount: int, source: String):
	"""Handle hot dog production events"""
	print("Game: Hot dogs produced - %d from %s" % [amount, source])
	
	# Show floating text for hot dog gain
	if floating_text_manager and hot_dog_display:
		var display_position = hot_dog_display.global_position
		print("Game: Showing hot dog gain floating text at position: ", display_position)
		floating_text_manager.show_hot_dog_gain(amount, display_position)
	else:
		print("Game: Cannot show floating text - manager: ", floating_text_manager, ", display: ", hot_dog_display)

func _on_hot_dogs_sold(amount: int, value: int):
	"""Handle hot dog sales events"""
	print("Game: Hot dogs sold - %d for %d currency" % [amount, value])

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Handle currency balance changes"""
	_update_currency_icon_display()

func _on_currency_earned(amount: int, source: String):
	"""Handle currency earned events"""
	print("Game: Currency earned - %d from %s" % [amount, source])
	
	# Show floating text for currency gain
	if floating_text_manager and currency_display:
		var display_position = currency_display.global_position
		print("Game: Showing currency gain floating text at position: ", display_position)
		floating_text_manager.show_currency_gain(amount, display_position)
	else:
		print("Game: Cannot show currency floating text - manager: ", floating_text_manager, ", display: ", currency_display)

func _on_currency_spent(amount: int, reason: String):
	"""Handle currency spent events"""
	print("Game: Currency spent - %d for %s" % [amount, reason])

func _on_customer_purchase(amount: int, value: int):
	"""Handle customer purchase events"""
	print("Game: Customer purchased %d hot dogs for %d currency" % [amount, value])

func _on_customer_arrived():
	"""Handle customer arrival events"""
	print("Game: Customer arrived")

func _on_click_completed(click_type: String, hot_dogs_produced: int):
	"""Handle click completion events"""
	print("Game: Click completed - %s produced %d hot dogs" % [click_type, hot_dogs_produced])

func _on_upgrade_icon_pressed():
	"""Handle upgrade icon press"""
	print("Game: Upgrade icon pressed")
	if upgrade_panel:
		upgrade_panel.visible = !upgrade_panel.visible

func _on_save_icon_pressed():
	"""Handle save icon press"""
	print("Game: Save icon pressed")
	if save_system:
		save_system.save_game("autosave")

func _on_exit_icon_pressed():
	"""Handle exit icon press"""
	print("Game: Exit icon pressed")
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _update_currency_icon_display():
	"""Update currency icon tooltip with current balance"""
	if currency_icon and hot_dog_manager:
		var formatted_currency = hot_dog_manager.get_formatted_currency()
		currency_icon.tooltip_text = formatted_currency

func display_game_data():
	"""Display current game data for debugging"""
	print("Game: Displaying current game data")
	
	if hot_dog_manager:
		print("  Hot Dogs: %d (per click: %d)" % [hot_dog_manager.hot_dogs_inventory, hot_dog_manager.hot_dogs_per_click])
		print("  Currency: %d (sale value: %d)" % [hot_dog_manager.currency_balance, hot_dog_manager.sale_value])
		print("  Production Rate: %.2fs" % hot_dog_manager.production_rate_seconds)
		print("  Idle Rate: %.2fs" % hot_dog_manager.idle_rate_seconds)
	
	if customer_manager:
		print("  Customer Purchase Rate: %.2fs" % customer_manager.get_purchase_rate())
		print("  Customers per minute: %.1f" % customer_manager.get_customers_per_minute())
	
	# Update displays
	_update_currency_icon_display() 
