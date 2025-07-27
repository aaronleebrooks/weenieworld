extends Control

@onready var top_left_menu = $TopLeftMenu
@onready var currency_icon = $TopLeftMenu/CurrencyIcon
@onready var upgrade_icon = $TopLeftMenu/UpgradeIcon
@onready var save_icon = $TopLeftMenu/SaveIcon
@onready var exit_icon = $TopLeftMenu/ExitIcon
@onready var upgrade_panel = $UpgradePanel
@onready var hello_world_label = $HelloWorldLabel

# Floating text system
var floating_text_scene = preload("res://scenes/ui/FloatingText.tscn")
var floating_text_pool: Array[Node] = []
var max_floating_texts: int = 10

# Dialog management
var exit_dialog_open: bool = false

# Tooltip management
var tooltips_always_visible: bool = false
var tooltip_toggle_button: Button
var icon_labels: Dictionary = {}  # Store label nodes for each icon
var icon_containers: Dictionary = {}  # Store container references

func _ready():
	print("Game: _ready() called")
	
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
	
	# Connect to currency changes to update display
	var currency_manager = get_node("/root/CurrencyManager")
	if currency_manager:
		currency_manager.currency_changed.connect(_on_currency_changed)
		currency_manager.currency_gained.connect(_on_currency_gained)
		currency_manager.currency_changed.connect(_update_currency_icon_display)
		currency_manager.currency_gained.connect(_update_currency_icon_display)
		currency_manager.currency_spent.connect(_update_currency_icon_display)
	
	# Connect to click manager for currency gain events
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

func _create_tooltip_toggle():
	"""Create the tooltip toggle button (caret icon)"""
	tooltip_toggle_button = Button.new()
	tooltip_toggle_button.text = "▼"  # Down arrow (caret)
	tooltip_toggle_button.custom_minimum_size = Vector2(30, 30)
	tooltip_toggle_button.pressed.connect(_on_tooltip_toggle_pressed)
	
	# Add styling to make it more visible
	tooltip_toggle_button.add_theme_color_override("font_color", Color.WHITE)
	tooltip_toggle_button.add_theme_color_override("font_hover_color", Color.YELLOW)
	tooltip_toggle_button.tooltip_text = "Toggle tooltips"
	
	# Add to top-left menu
	top_left_menu.add_child(tooltip_toggle_button)
	top_left_menu.move_child(tooltip_toggle_button, 0)  # Move to top
	
	print("DEBUG: Tooltip toggle button created")
	print("DEBUG: Tooltip toggle button connected to signal: ", tooltip_toggle_button.pressed.get_connections().size(), " connections")

func _setup_currency_icon():
	"""Setup currency icon as non-clickable with blue text"""
	currency_icon.disabled = true  # Make it non-clickable
	currency_icon.add_theme_color_override("font_color", Color.BLUE)
	currency_icon.add_theme_color_override("font_disabled_color", Color.BLUE)
	print("DEBUG: Currency icon set to non-clickable with blue text")

func _get_currency_display_text() -> String:
	"""Get the current currency value as formatted text"""
	var currency_manager = get_node("/root/CurrencyManager")
	if currency_manager:
		return currency_manager.get_formatted_currency()
	return "0"

func _update_currency_icon_display(param1 = 0, param2 = ""):
	"""Update the currency icon tooltip and label with current currency value"""
	var currency_text = _get_currency_display_text()
	
	# Update tooltip if tooltips are enabled
	if not tooltips_always_visible:
		currency_icon.tooltip_text = currency_text
	
	# Update label if labels are visible
	if icon_labels.has(currency_icon):
		var label = icon_labels[currency_icon]
		if label and label.visible:
			label.text = currency_text

func _setup_tooltips():
	"""Setup tooltips for all icons"""
	_setup_icon_tooltip(currency_icon, _get_currency_display_text())
	_setup_icon_tooltip(upgrade_icon, "Upgrades")
	_setup_icon_tooltip(save_icon, "Save Game")
	_setup_icon_tooltip(exit_icon, "Exit Game")
	print("DEBUG: Tooltips setup completed")

func _setup_icon_tooltip(icon: Button, tooltip_text: String):
	"""Setup tooltip for a specific icon"""
	# Set tooltip to show instantly
	icon.tooltip_text = tooltip_text
	
	# Set tooltip to show immediately on hover (0 delay)
	icon.add_theme_constant_override("tooltip_delay", 0)
	
	# Create HBoxContainer to group icon and label
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 5)  # Small gap between icon and label
	
	# Create label for header name
	var label = Label.new()
	label.text = tooltip_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.visible = false  # Initially hidden
	label.custom_minimum_size = Vector2(80, 0)  # Fixed width for label
	
	# Get the icon's current position in the menu
	var icon_index = icon.get_index()
	
	# Remove icon from menu temporarily
	top_left_menu.remove_child(icon)
	
	# Add icon and label to container
	container.add_child(icon)
	container.add_child(label)
	
	# Add container to menu at the same position
	top_left_menu.add_child(container)
	top_left_menu.move_child(container, icon_index)
	
	# Store references
	icon_labels[icon] = label
	icon_containers[icon] = container
	
	# Connect mouse enter/exit events for hover behavior
	icon.mouse_entered.connect(_on_icon_mouse_entered.bind(icon))
	icon.mouse_exited.connect(_on_icon_mouse_exited.bind(icon))
	
	# Initially hide tooltip if not always visible
	if not tooltips_always_visible:
		icon.tooltip_text = ""
	
	print("DEBUG: Created container for icon: ", tooltip_text)

func _on_tooltip_toggle_pressed():
	"""Toggle tooltip visibility"""
	print("DEBUG: Tooltip toggle button pressed!")
	tooltips_always_visible = !tooltips_always_visible
	
	# Update toggle button appearance
	if tooltips_always_visible:
		tooltip_toggle_button.text = "▲"  # Up arrow
		_show_all_labels()
		_disable_all_tooltips()  # Disable tooltips when labels are shown
		print("DEBUG: Labels shown, tooltips disabled")
	else:
		tooltip_toggle_button.text = "▼"  # Down arrow
		_hide_all_labels()
		_enable_all_tooltips()  # Enable tooltips when labels are hidden
		print("DEBUG: Labels hidden, tooltips enabled")
	
	print("DEBUG: Tooltips always visible: ", tooltips_always_visible)

func _show_all_labels():
	"""Show header name labels for all icons"""
	for icon in icon_labels:
		var label = icon_labels[icon]
		if label:
			label.visible = true
			# Update currency label with current value
			if icon == currency_icon:
				label.text = _get_currency_display_text()
	print("DEBUG: All labels shown")

func _hide_all_labels():
	"""Hide header name labels for all icons"""
	for icon in icon_labels:
		var label = icon_labels[icon]
		if label:
			label.visible = false
	print("DEBUG: All labels hidden")

func _disable_all_tooltips():
	"""Disable tooltips for all icons"""
	for icon in icon_labels:
		icon.tooltip_text = ""
	print("DEBUG: All tooltips disabled")

func _enable_all_tooltips():
	"""Enable tooltips for all icons"""
	for icon in icon_labels:
		var tooltip_text = ""
		if icon == currency_icon:
			tooltip_text = _get_currency_display_text()
		elif icon == upgrade_icon:
			tooltip_text = "Upgrades"
		elif icon == save_icon:
			tooltip_text = "Save Game"
		elif icon == exit_icon:
			tooltip_text = "Exit Game"
		icon.tooltip_text = tooltip_text
	print("DEBUG: All tooltips enabled")

func _on_icon_mouse_entered(icon: Button):
	"""Show tooltip on mouse enter if not always visible"""
	if not tooltips_always_visible:
		var tooltip_text = ""
		if icon == currency_icon:
			tooltip_text = _get_currency_display_text()
		elif icon == upgrade_icon:
			tooltip_text = "Upgrades"
		elif icon == save_icon:
			tooltip_text = "Save Game"
		elif icon == exit_icon:
			tooltip_text = "Exit Game"
		
		icon.tooltip_text = tooltip_text
		print("DEBUG: Tooltip shown for icon: ", tooltip_text)

func _on_icon_mouse_exited(icon: Button):
	"""Hide tooltip on mouse exit if not always visible"""
	if not tooltips_always_visible:
		icon.tooltip_text = ""
		print("DEBUG: Tooltip hidden for icon")

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
	
	# Update icon menu sizing
	if top_left_menu:
		var icon_size = max(30, min(viewport_size.x * 0.02, 50))  # 2% of viewport width
		print("DEBUG: Processing ", top_left_menu.get_child_count(), " children in top_left_menu")
		
		for child in top_left_menu.get_children():
			if child is Button:
				# Handle standalone buttons (like tooltip toggle)
				child.custom_minimum_size = Vector2(icon_size, icon_size)
				child.add_theme_font_size_override("font_size", icon_size * 0.6)
				
				# Special handling for tooltip toggle button
				if child == tooltip_toggle_button:
					child.add_theme_font_size_override("font_size", icon_size * 0.4)  # Smaller font for caret
					print("DEBUG: Tooltip toggle button sized")
			elif child is HBoxContainer:
				# Handle icon-label containers
				print("DEBUG: Processing HBoxContainer with ", child.get_child_count(), " children")
				for container_child in child.get_children():
					if container_child is Button:
						# Icon button
						container_child.custom_minimum_size = Vector2(icon_size, icon_size)
						container_child.add_theme_font_size_override("font_size", icon_size * 0.6)
						print("DEBUG: Icon sized in container: ", container_child.text)
					elif container_child is Label:
						# Label next to icon
						var label_font_size = max(10, min(icon_size * 0.4, 14))  # Slightly larger font for labels
						container_child.add_theme_font_size_override("font_size", label_font_size)
						container_child.custom_minimum_size = Vector2(80, icon_size)  # Match icon height
						print("DEBUG: Label sized in container: ", container_child.text)
		
		print("Game: Icon menu updated with percentage-based sizing")

func _on_upgrade_icon_pressed():
	print("Opening upgrade panel...")
	upgrade_panel.show_panel()

func _on_save_icon_pressed():
	print("Manual save requested...")
	var success = get_node("/root/SaveSystem").create_manual_save()
	if success:
		print("Manual save created successfully!")
	else:
		print("Failed to create manual save!")

func _on_exit_icon_pressed():
	print("Exit icon pressed - showing confirmation dialog")
	_show_exit_confirmation()

func _show_exit_confirmation():
	"""Show confirmation dialog before returning to menu"""
	# Debug: Check current state
	_debug_dialog_state("Before showing exit confirmation")
	
	# Check for any existing dialog panels in the scene tree
	var all_dialogs = get_tree().get_nodes_in_group("confirmation_dialogs")
	var all_panels = get_tree().get_nodes_in_group("dialog_panels")
	print("DEBUG: Found ", all_dialogs.size(), " dialogs in confirmation_dialogs group")
	print("DEBUG: Found ", all_panels.size(), " panels in dialog_panels group")
	
	# Check for any ConfirmationDialog instances in the entire scene tree
	var all_confirmation_dialogs = []
	_find_confirmation_dialogs(get_tree().current_scene, all_confirmation_dialogs)
	print("DEBUG: Found ", all_confirmation_dialogs.size(), " confirmation dialogs in scene tree")
	
	# Prevent multiple dialogs from being created
	if exit_dialog_open:
		print("DEBUG: Exit dialog already open, ignoring request")
		return
	
	# Check if there are any existing ConfirmationDialog instances
	var existing_dialogs = get_tree().get_nodes_in_group("confirmation_dialogs")
	if existing_dialogs.size() > 0 or all_confirmation_dialogs.size() > 0:
		print("DEBUG: Found existing confirmation dialogs, cleaning up")
		# Force close any existing dialogs
		for dialog in existing_dialogs:
			if is_instance_valid(dialog):
				dialog.queue_free()
		for dialog in all_confirmation_dialogs:
			if is_instance_valid(dialog):
				dialog.queue_free()
		exit_dialog_open = false
		# Wait a frame to ensure cleanup
		await get_tree().process_frame
	
	print("DEBUG: Creating new exit confirmation dialog")
	exit_dialog_open = true
	var dialog = preload("res://scenes/ui/ConfirmationDialog.tscn").instantiate()
	
	# Add to a group for tracking
	dialog.add_to_group("confirmation_dialogs")
	
	# Set the dialog text
	var title_node = dialog.get_node("DialogPanel/VBoxContainer/Title")
	var message_node = dialog.get_node("DialogPanel/VBoxContainer/Message")
	
	if title_node:
		title_node.text = "Exit Game"
		print("DEBUG: Set dialog title to: Exit Game")
	if message_node:
		message_node.text = "Are you sure you want to return to the main menu?\nYour progress will be saved automatically."
		print("DEBUG: Set dialog message")
	
	dialog.confirmed.connect(_on_exit_confirmed)
	dialog.cancelled.connect(_on_exit_cancelled)
	add_child(dialog)
	print("DEBUG: Dialog added to scene tree")
	print("DEBUG: Dialog parent = ", dialog.get_parent().name if dialog.get_parent() else "No parent")
	print("DEBUG: Dialog scene path = ", dialog.get_path())
	print("DEBUG: Current scene name = ", get_tree().current_scene.name if get_tree().current_scene else "No current scene")
	
	# Debug: Check state after creation
	_debug_dialog_state("After showing exit confirmation")

func _find_confirmation_dialogs(node: Node, dialogs: Array):
	"""Recursively find all ConfirmationDialog instances in the scene tree"""
	if node.get_script() and node.get_script().get_global_name() == "res://scenes/ui/ConfirmationDialog.gd":
		dialogs.append(node)
	
	for child in node.get_children():
		_find_confirmation_dialogs(child, dialogs)

func _on_exit_confirmed():
	print("DEBUG: Exit confirmed - returning to main menu...")
	_debug_dialog_state("Before exit confirmed")
	exit_dialog_open = false
	get_node("/root/GameManager").return_to_main_menu()

func _on_exit_cancelled():
	print("DEBUG: Exit cancelled - staying in game")
	_debug_dialog_state("Before exit cancelled")
	exit_dialog_open = false
	_debug_dialog_state("After exit cancelled")

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

# Manual save functionality moved to icon menu

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Update display when currency changes"""
	display_game_data()

func _on_currency_gained(amount: int, source: String):
	"""Handle currency gain events"""
	# Show floating text for currency gains
	show_floating_text(amount, get_currency_gain_position())

func _on_click_completed(click_type: String, currency_gained: int):
	"""Handle click completion events"""
	# Note: Floating text is already shown by _on_currency_gained
	# No need to show it again here to avoid duplicates
	pass

func show_floating_text(amount: int, position: Vector2):
	"""Show floating text for currency gain"""
	var floating_text = get_floating_text()
	if floating_text:
		floating_text.show_currency_gain(amount, position)

func get_floating_text() -> Node:
	"""Get a floating text instance from pool or create new one"""
	# Try to find an available floating text
	for text in floating_text_pool:
		if not text.visible:
			return text
	
	# Create new floating text if pool is not full
	if floating_text_pool.size() < max_floating_texts:
		var new_text = floating_text_scene.instantiate()
		floating_text_pool.append(new_text)
		add_child(new_text)
		return new_text
	
	# Reuse the oldest floating text if pool is full
	if floating_text_pool.size() > 0:
		return floating_text_pool[0]
	
	return null

func get_currency_gain_position() -> Vector2:
	"""Get position for currency gain floating text"""
	# Position near the currency gain button, but offset to avoid overlap
	var button = get_node_or_null("CurrencyGainButton")
	if button:
		# Add some randomness to prevent overlap and offset from button
		var random_offset = Vector2(randf_range(-20, 20), randf_range(-40, -20))
		return button.global_position + random_offset
	else:
		# Fallback to center of screen
		return get_viewport().get_visible_rect().size / 2

func _input(event):
	# Handle escape key to return to menu only if no dialog is open
	if event.is_action_pressed("ui_cancel"):
		# Check if there are any confirmation dialogs open
		var existing_dialogs = get_tree().get_nodes_in_group("confirmation_dialogs")
		if existing_dialogs.size() == 0:
			print("DEBUG: No dialogs open, handling escape key")
			_on_exit_icon_pressed()
		else:
			print("DEBUG: Dialog is open, letting dialog handle escape key")
	
	# Test animations with 'T' key
	if event.is_action_pressed("test_animations") and event.pressed:
		var animation_manager = get_node("/root/AnimationManager")
		if animation_manager:
			animation_manager.test_animations() 

func _debug_dialog_state(context: String):
	"""Debug method to check current dialog state"""
	var existing_dialogs = get_tree().get_nodes_in_group("confirmation_dialogs")
	print("DEBUG: [", context, "] exit_dialog_open = ", exit_dialog_open, ", existing_dialogs = ", existing_dialogs.size())
	for i in range(existing_dialogs.size()):
		var dialog = existing_dialogs[i]
		var is_closing = false
		if dialog.has_method("get") and dialog.get("is_closing") != null:
			is_closing = dialog.get("is_closing")
		print("DEBUG: [", context, "] Dialog ", i, " valid = ", is_instance_valid(dialog), " closing = ", is_closing) 
