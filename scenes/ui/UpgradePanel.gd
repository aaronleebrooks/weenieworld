extends Control

# Upgrade panel for displaying and purchasing upgrades
# Uses intentional naming conventions for future maintainability
# Implements tab-based navigation between Kitchen Upgrades and Buildings

const UpgradeEnums = preload("res://scripts/resources/UpgradeEnums.gd")

@onready var kitchen_upgrade_container = $SubMenuContainer/KitchenUpgrades/KitchenUpgradeContainer
@onready var building_container = $SubMenuContainer/Buildings/BuildingContainer
@onready var kitchen_upgrades_scroll = $SubMenuContainer/KitchenUpgrades
@onready var buildings_scroll = $SubMenuContainer/Buildings
@onready var kitchen_tab = $TabContainer/KitchenTab
@onready var buildings_tab = $TabContainer/BuildingsTab
@onready var back_button = $BackButton
@onready var currency_display = $CurrencyDisplay

var upgrade_manager: Node
var hot_dog_manager: Node
var building_manager: Node
var upgrade_buttons: Array[Button] = []
var building_buttons: Array[Button] = []

# Submenu state
enum SubmenuType { KITCHEN_UPGRADES, BUILDINGS }
var current_submenu: SubmenuType = SubmenuType.KITCHEN_UPGRADES

const DEBUG_MODE: bool = false

func _ready():
	print("UpgradePanel: Initialized with tab-based navigation")
	
	# Get references to managers
	upgrade_manager = get_node("/root/UpgradeManager")
	hot_dog_manager = get_node("/root/HotDogManager")
	building_manager = get_node_or_null("/root/BuildingManager")
	
	# Connect signals
	back_button.pressed.connect(_on_back_button_pressed)
	kitchen_tab.pressed.connect(_on_kitchen_tab_pressed)
	buildings_tab.pressed.connect(_on_buildings_tab_pressed)
	
	# Connect to currency changes to update button states
	if hot_dog_manager:
		hot_dog_manager.currency_changed.connect(_on_currency_changed)
	
	# Connect to upgrade purchases
	if upgrade_manager:
		upgrade_manager.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Start hidden
	visible = false
	
	# Create upgrade buttons and set initial submenu
	_create_upgrade_buttons()
	_switch_to_submenu(SubmenuType.KITCHEN_UPGRADES)
	
	# Initial currency display update
	_update_currency_display()

func _create_upgrade_buttons():
	"""Create buttons for all available upgrades in Kitchen submenu"""
	if not upgrade_manager:
		if DEBUG_MODE:
			print("UpgradePanel: UpgradeManager not available")
		return
	
	var kitchen_upgrades = upgrade_manager.get_upgrades_by_category(UpgradeEnums.UpgradeCategory.KITCHEN)
	for upgrade in kitchen_upgrades:
		var button = _create_upgrade_button(upgrade)
		kitchen_upgrade_container.add_child(button)
		upgrade_buttons.append(button)
	
	print("UpgradePanel: Created %d kitchen upgrade buttons" % upgrade_buttons.size())

func _create_building_buttons():
	"""Create buttons for building purchases"""
	if not building_manager:
		if DEBUG_MODE:
			print("UpgradePanel: BuildingManager not available")
		return
	
	var buildings = building_manager.get_all_buildings()
	for building in buildings:
		var button = _create_building_button(building)
		building_container.add_child(button)
		building_buttons.append(button)
	
	# Connect to building purchase signals
	if not building_manager.building_purchased.is_connected(_on_building_purchased):
		building_manager.building_purchased.connect(_on_building_purchased)
	
	print("UpgradePanel: Created %d building buttons" % building_buttons.size())

func _create_upgrade_button(upgrade) -> Button:
	"""Create a button for a specific upgrade"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 60)
	button.text = _get_upgrade_button_text(upgrade)
	button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade.upgrade_id))
	
	# Store upgrade info in button metadata
	button.set_meta("upgrade_id", upgrade.upgrade_id)
	
	return button

func _create_building_button(building) -> Button:
	"""Create a button for a specific building"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 80)
	button.text = _get_building_button_text(building)
	button.pressed.connect(_on_building_button_pressed.bind(building.building_id))
	
	# Store building info in button metadata
	button.set_meta("building_id", building.building_id)
	
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

func _get_building_button_text(building) -> String:
	"""Get the text to display on a building button"""
	if not building_manager:
		return building.display_name
	
	var info = building_manager.get_building_info(building.building_id)
	var is_purchased = info.get("is_purchased", false)
	var is_unlocked = info.get("is_unlocked", false)
	var can_purchase = info.get("can_purchase", false)
	
	var text = "%s" % building.display_name
	text += "\n%s" % building.description
	
	if is_purchased:
		text += "\nPURCHASED ✓"
	elif not is_unlocked:
		text += "\nLOCKED (Need %d total currency earned)" % building.unlock_condition_value
	elif can_purchase:
		text += "\nCost: %d currency" % building.base_cost
	else:
		text += "\nCost: %d (Can't afford)" % building.base_cost
	
	return text

func _switch_to_submenu(submenu_type: SubmenuType):
	"""Switch between Kitchen Upgrades and Buildings submenus"""
	current_submenu = submenu_type
	
	# Update tab button states
	kitchen_tab.disabled = (submenu_type == SubmenuType.KITCHEN_UPGRADES)
	buildings_tab.disabled = (submenu_type == SubmenuType.BUILDINGS)
	
	# Show/hide appropriate containers
	kitchen_upgrades_scroll.visible = (submenu_type == SubmenuType.KITCHEN_UPGRADES)
	buildings_scroll.visible = (submenu_type == SubmenuType.BUILDINGS)
	
	# Update building buttons if switching to buildings
	if submenu_type == SubmenuType.BUILDINGS:
		_update_buildings_submenu()
	
	if DEBUG_MODE:
		print("UpgradePanel: Switched to submenu: ", submenu_type)

func _update_buildings_submenu():
	"""Update the buildings submenu visibility and content"""
	# Check if buildings should be unlocked (after earning 100 currency)
	var buildings_unlocked = _check_buildings_unlock()
	
	if buildings_unlocked:
		buildings_tab.disabled = false
		buildings_tab.modulate = Color.WHITE
		
		# Create building buttons if not already created
		if building_buttons.is_empty():
			_create_building_buttons()
	else:
		buildings_tab.disabled = true
		buildings_tab.modulate = Color.GRAY
		
		# If currently on buildings tab but it's locked, switch to kitchen
		if current_submenu == SubmenuType.BUILDINGS:
			_switch_to_submenu(SubmenuType.KITCHEN_UPGRADES)

func _check_buildings_unlock() -> bool:
	"""Check if buildings submenu should be unlocked (after earning 100 currency)"""
	if not hot_dog_manager:
		return false
	
	# Unlock buildings after earning 100 total currency
	return hot_dog_manager.total_currency_earned >= 100

func _on_kitchen_tab_pressed():
	"""Handle Kitchen Upgrades tab button press"""
	_switch_to_submenu(SubmenuType.KITCHEN_UPGRADES)

func _on_buildings_tab_pressed():
	"""Handle Buildings tab button press"""
	if _check_buildings_unlock():
		_switch_to_submenu(SubmenuType.BUILDINGS)
	else:
		if DEBUG_MODE:
			print("UpgradePanel: Buildings submenu still locked")

func _on_upgrade_button_pressed(upgrade_id: String):
	"""Handle upgrade button press"""
	if not upgrade_manager:
		return
	
	if upgrade_manager.purchase_upgrade(upgrade_id):
		print("UpgradePanel: Successfully purchased upgrade: ", upgrade_id)
		_update_all_buttons()
	else:
		print("UpgradePanel: Failed to purchase upgrade: ", upgrade_id)

func _on_building_button_pressed(building_id: String):
	"""Handle building button press"""
	if not building_manager:
		return
	
	if building_manager.purchase_building(building_id):
		print("UpgradePanel: Successfully purchased building: ", building_id)
		_update_all_buttons()
	else:
		print("UpgradePanel: Failed to purchase building: ", building_id)

func _on_building_purchased(building_id: String, cost: int):
	"""Handle building purchase event"""
	_update_all_buttons()
	if DEBUG_MODE:
		print("UpgradePanel: Building purchased event received: ", building_id)

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Update button states when currency changes"""
	_update_all_buttons()
	_update_currency_display()
	_update_buildings_submenu()

func _on_upgrade_purchased(upgrade_id: String, level: int, cost: int):
	"""Update buttons when an upgrade is purchased"""
	_update_all_buttons()

func _update_all_buttons():
	"""Update all upgrade and building button texts and states"""
	# Update upgrade buttons
	for button in upgrade_buttons:
		var upgrade_id = button.get_meta("upgrade_id")
		if upgrade_id:
			var info = upgrade_manager.get_upgrade_info(upgrade_id)
			button.text = _get_upgrade_button_text(info["upgrade"])
			button.disabled = not info.get("can_purchase", false)
	
	# Update building buttons
	if building_manager:
		for button in building_buttons:
			var building_id = button.get_meta("building_id")
			if building_id:
				var info = building_manager.get_building_info(building_id)
				if info:
					button.text = _get_building_button_text(info["building"])
					button.disabled = not info.get("can_purchase", false)

func _update_currency_display():
	"""Update the currency display with current currency value"""
	if currency_display and hot_dog_manager:
		var formatted_currency = hot_dog_manager.get_formatted_currency()
		currency_display.text = "Currency: %s" % formatted_currency

func _on_back_button_pressed():
	"""Hide the upgrade panel"""
	visible = false

func show_panel():
	"""Show the upgrade panel and update buttons"""
	visible = true
	_update_all_buttons()
	_update_currency_display()
	_update_buildings_submenu() 
