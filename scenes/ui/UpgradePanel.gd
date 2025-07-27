extends Control

# Upgrade panel for displaying and purchasing upgrades
# Uses intentional naming conventions for future maintainability

@onready var upgrade_container = $UpgradeContainer
@onready var back_button = $BackButton
@onready var currency_display = $CurrencyDisplay

var upgrade_manager: Node
var currency_manager: Node
var upgrade_buttons: Array[Button] = []

func _ready():
	print("UpgradePanel: Initialized")
	
	# Get references to managers
	upgrade_manager = get_node("/root/UpgradeManager")
	currency_manager = get_node("/root/CurrencyManager")
	
	# Connect signals
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Connect to currency changes to update button states
	if currency_manager:
		currency_manager.currency_changed.connect(_on_currency_changed)
	
	# Connect to upgrade purchases
	if upgrade_manager:
		upgrade_manager.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Start hidden
	visible = false
	
	# Create upgrade buttons
	_create_upgrade_buttons()
	
	# Initial currency display update
	_update_currency_display()

func _create_upgrade_buttons():
	"""Create buttons for all available upgrades"""
	if not upgrade_manager:
		return
	
	var upgrades = upgrade_manager.get_all_upgrades()
	for upgrade in upgrades:
		var button = _create_upgrade_button(upgrade)
		upgrade_container.add_child(button)
		upgrade_buttons.append(button)
	
	print("UpgradePanel: Created %d upgrade buttons" % upgrade_buttons.size())

func _create_upgrade_button(upgrade) -> Button:
	"""Create a button for a specific upgrade"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 60)
	button.text = _get_upgrade_button_text(upgrade)
	button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade.upgrade_id))
	
	# Store upgrade info in button metadata
	button.set_meta("upgrade_id", upgrade.upgrade_id)
	
	return button

func _get_upgrade_button_text(upgrade) -> String:
	"""Get the text to display on an upgrade button"""
	if not upgrade_manager:
		return upgrade.display_name
	
	var info = upgrade_manager.get_upgrade_info(upgrade.upgrade_id)
	var level = info.get("level", 0)
	var cost = info.get("cost", 0)
	var can_purchase = info.get("can_purchase", false)
	var is_max_level = info.get("is_max_level", false)
	
	var text = "%s (Level %d)" % [upgrade.display_name, level]
	text += "\n%s" % upgrade.description
	
	if not is_max_level:
		text += "\nCost: %d" % cost
		if not can_purchase:
			text += " (Can't afford)"
	else:
		text += "\nMAX LEVEL"
	
	return text

func _on_upgrade_button_pressed(upgrade_id: String):
	"""Handle upgrade button press"""
	if not upgrade_manager:
		return
	
	if upgrade_manager.purchase_upgrade(upgrade_id):
		print("UpgradePanel: Successfully purchased upgrade: ", upgrade_id)
		_update_all_buttons()
	else:
		print("UpgradePanel: Failed to purchase upgrade: ", upgrade_id)

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Update button states when currency changes"""
	_update_all_buttons()
	_update_currency_display()

func _on_upgrade_purchased(upgrade_id: String, level: int, cost: int):
	"""Update buttons when an upgrade is purchased"""
	_update_all_buttons()

func _update_all_buttons():
	"""Update all upgrade button texts and states"""
	for button in upgrade_buttons:
		var upgrade_id = button.get_meta("upgrade_id")
		if upgrade_id:
			var info = upgrade_manager.get_upgrade_info(upgrade_id)
			button.text = _get_upgrade_button_text(info["upgrade"])
			button.disabled = not info.get("can_purchase", false)

func _update_currency_display():
	"""Update the currency display with current currency value"""
	if currency_display and currency_manager:
		var formatted_currency = currency_manager.get_formatted_currency()
		currency_display.text = formatted_currency

func _on_back_button_pressed():
	"""Hide the upgrade panel"""
	visible = false

func show_panel():
	"""Show the upgrade panel and update buttons"""
	visible = true
	_update_all_buttons()
	_update_currency_display() 
