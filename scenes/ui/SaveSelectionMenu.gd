extends Control

@onready var save_list = $SaveList
@onready var back_button = $BackButton
@onready var title = $Title

var save_buttons: Array[Button] = []
var save_containers: Array[Control] = []
var delete_dialog_open: bool = false

func _ready():
	print("SaveSelectionMenu: Initialized")
	
	# Connect button signals
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Connect to viewport size changes for responsive sizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial responsive sizing
	_update_responsive_layout()
	
	# Populate save list
	populate_save_list()

func _on_viewport_size_changed():
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive font size
	var font_size_percent = viewport_size.x * 0.02  # 2% of viewport width
	var responsive_font_size = max(14, min(font_size_percent, 32))  # 14px to 32px
	
	# Update title font size
	if title:
		title.add_theme_font_size_override("font_size", responsive_font_size * 1.2)
	
	# Update back button font size
	if back_button:
		back_button.add_theme_font_size_override("font_size", responsive_font_size)
	
	print("SaveSelectionMenu: Font sizes updated to ", responsive_font_size)

func populate_save_list():
	"""Populate the save list with available saves"""
	print("SaveSelectionMenu: Populating save list")
	
	# Clear existing save buttons
	for container in save_containers:
		if is_instance_valid(container):
			container.queue_free()
	save_containers.clear()
	save_buttons.clear()
	
	# Get save list from SaveSystem
	var save_system = get_node("/root/SaveSystem")
	if not save_system:
		print("SaveSelectionMenu: SaveSystem not found")
		return
	
	var saves = save_system.get_save_list()
	print("SaveSelectionMenu: Found %d saves" % saves.size())
	
	if saves.is_empty():
		_show_no_saves_message()
		return
	
	# Create save buttons for each save
	for save_info in saves:
		_create_save_button(save_info)

func _show_no_saves_message():
	"""Show message when no saves are available"""
	var no_saves_label = Label.new()
	no_saves_label.text = "No save files found"
	no_saves_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_saves_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	no_saves_label.add_theme_font_size_override("font_size", 18)
	no_saves_label.add_theme_color_override("font_color", Color.GRAY)
	no_saves_label.custom_minimum_size = Vector2(0, 100)
	save_list.add_child(no_saves_label)

func _create_save_button(save_info: Dictionary):
	"""Create a button for a specific save"""
	var viewport_size = get_viewport().get_visible_rect().size
	var button_height_percent = viewport_size.y * 0.06  # 6% of viewport height
	var button_height = max(40, min(button_height_percent, 80))  # 40px to 80px
	var responsive_font_size = max(14, min(viewport_size.x * 0.015, 24))  # 14px to 24px
	
	# Create container for save button and delete button
	var save_container = HBoxContainer.new()
	save_container.custom_minimum_size = Vector2(0, button_height + 10)
	save_container.add_theme_constant_override("separation", 15)
	save_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Create load button
	var load_button = Button.new()
	var formatted_time = format_timestamp(save_info["modified_time"])
	load_button.text = save_info["name"] + "\n" + formatted_time
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.custom_minimum_size = Vector2(0, button_height)
	load_button.add_theme_font_size_override("font_size", responsive_font_size - 2)
	load_button.pressed.connect(_on_save_selected.bind(save_info))
	save_container.add_child(load_button)
	save_buttons.append(load_button)
	
	# Create delete button
	var delete_button = Button.new()
	delete_button.text = "X"
	delete_button.custom_minimum_size = Vector2(button_height * 0.75, button_height)
	delete_button.add_theme_font_size_override("font_size", responsive_font_size)
	delete_button.add_theme_color_override("font_color", Color.RED)
	delete_button.add_theme_color_override("font_hover_color", Color.RED)
	delete_button.pressed.connect(_on_delete_save_pressed.bind(save_info))
	save_container.add_child(delete_button)
	
	save_list.add_child(save_container)
	save_containers.append(save_container)

func _on_save_selected(save_info: Dictionary):
	print("Loading save: ", save_info["name"])
	
	# Load the selected save
	var game_manager = get_node("/root/GameManager")
	game_manager.load_specific_save(save_info["name"])
	
	# Close this menu and go to game
	queue_free()

func _on_delete_save_pressed(save_info: Dictionary):
	show_delete_confirmation(save_info)

func show_delete_confirmation(save_info: Dictionary):
	# Prevent multiple dialogs from being created
	if delete_dialog_open:
		print("Delete dialog already open, ignoring request")
		return
	
	delete_dialog_open = true
	var dialog_scene = preload("res://scenes/ui/ConfirmationDialog.tscn")
	var dialog = dialog_scene.instantiate()
	dialog.setup(save_info)
	dialog.confirmed.connect(_on_delete_confirmed.bind(save_info))
	dialog.cancelled.connect(_on_delete_cancelled)
	add_child(dialog)

func _on_delete_confirmed(save_info: Dictionary):
	print("Deleting save: ", save_info["name"])
	delete_dialog_open = false
	
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var success = save_system.delete_save(save_info["name"])
		print("Delete result: ", success)
	
	# Always refresh the list after attempting deletion
	print("Refreshing save list after deletion attempt...")
	populate_save_list()
	
	# Check if any saves remain after refresh
	var remaining_saves = save_system.get_save_list() if save_system else []
	print("Saves remaining after deletion and refresh: ", remaining_saves.size())
	
	if remaining_saves.is_empty():
		# No saves left, close the modal and update main menu
		print("No saves remaining, closing modal")
		var main_menu = get_parent()
		if main_menu.has_method("update_continue_button"):
			main_menu.update_continue_button()
		queue_free()
	else:
		print("Save list refreshed successfully")

func format_timestamp(timestamp: int) -> String:
	"""Convert Unix timestamp to readable format"""
	if timestamp <= 0:
		return "Unknown time"
	
	# Convert Unix timestamp to readable format
	var date_time = Time.get_datetime_string_from_unix_time(timestamp)
	return date_time

func _on_delete_cancelled():
	print("Delete cancelled")
	delete_dialog_open = false

func _on_back_button_pressed():
	queue_free() 
