extends Control

@onready var save_list = $MenuPanel/SaveList/SaveListContainer
@onready var no_saves_label = $MenuPanel/SaveList/SaveListContainer/NoSavesLabel
@onready var back_button = $MenuPanel/ButtonContainer/BackButton
@onready var menu_panel = $MenuPanel

var save_buttons = []
var save_containers = []
var main_menu = null

# Responsive modal properties
var min_width: float = 400.0
var min_height: float = 300.0
var max_width_percent: float = 0.8
var max_height_percent: float = 0.8

func _ready():
	print("SaveSelectionMenu: _ready() called")
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Connect to viewport size changes using native event system
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial size update
	_update_modal_size()
	
	populate_save_list()

func _on_viewport_size_changed():
	print("SaveSelectionMenu: Viewport size changed")
	_update_modal_size()

func _update_modal_size():
	var viewport_size = get_viewport().get_visible_rect().size
	print("SaveSelectionMenu: Viewport size = ", viewport_size)
	
	# Use percentage-based sizing (like CSS vw/vh units)
	var font_size_percent = viewport_size.x * 0.02  # 2% of viewport width
	var button_height_percent = viewport_size.y * 0.06  # 6% of viewport height
	
	# Set reasonable bounds
	var responsive_font_size = max(14, min(font_size_percent, 48))  # 14px to 48px
	var button_height = max(50, min(button_height_percent, 100))  # 50px to 100px
	
	print("SaveSelectionMenu: Font size = ", responsive_font_size, "px (", font_size_percent, "px raw), Button height = ", button_height, "px (", button_height_percent, "px raw)")
	
	# Update panel size using percentage-based approach
	var target_width = viewport_size.x * 0.6  # 60% of viewport width
	var target_height = viewport_size.y * 0.7  # 70% of viewport height
	
	# Ensure minimum size
	target_width = max(target_width, 400)
	target_height = max(target_height, 300)
	
	print("SaveSelectionMenu: Target size = ", Vector2(target_width, target_height))
	
	if menu_panel:
		print("SaveSelectionMenu: Updating panel size")
		menu_panel.offset_left = -target_width / 2
		menu_panel.offset_top = -target_height / 2
		menu_panel.offset_right = target_width / 2
		menu_panel.offset_bottom = target_height / 2
		
		# Update title font size
		var title = menu_panel.get_node_or_null("Title")
		if title:
			title.add_theme_font_size_override("font_size", responsive_font_size * 1.3)  # Title 30% larger
		
		# Update back button font size
		if back_button:
			back_button.add_theme_font_size_override("font_size", responsive_font_size)
		
		# Update existing save buttons font sizes
		for button in save_buttons:
			button.add_theme_font_size_override("font_size", responsive_font_size)
		
		print("SaveSelectionMenu: Panel updated with percentage-based sizing")
	else:
		print("SaveSelectionMenu: No menu_panel found")

func populate_save_list():
	print("Populating save list...")
	
	# Clear existing save containers
	for container in save_containers:
		container.queue_free()
	save_containers.clear()
	save_buttons.clear()
	
	# Get available save files
	var save_files = get_node("/root/SaveSystem").get_save_files()
	print("Found save files: ", save_files.size())
	
	if save_files.is_empty():
		print("No save files, showing 'No saves' label")
		no_saves_label.visible = true
		return
	
	print("Creating save entries for ", save_files.size(), " files")
	no_saves_label.visible = false
	
	# Calculate percentage-based sizes for new buttons (like CSS vw/vh)
	var viewport_size = get_viewport().get_visible_rect().size
	var font_size_percent = viewport_size.x * 0.02  # 2% of viewport width
	var button_height_percent = viewport_size.y * 0.06  # 6% of viewport height
	
	var responsive_font_size = max(14, min(font_size_percent, 48))  # 14px to 48px
	var button_height = max(50, min(button_height_percent, 100))  # 50px to 100px
	
	# Create containers for each save file
	for save_info in save_files:
		var save_container = HBoxContainer.new()
		save_container.custom_minimum_size = Vector2(0, button_height + 10)
		save_container.add_theme_constant_override("separation", 15)
		save_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Create load button
		var load_button = Button.new()
		var formatted_time = format_timestamp(save_info["time"])
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
	game_manager.load_specific_save(save_info)
	
	# Close this menu and go to game
	queue_free()
	get_node("/root/GameManager").change_scene(game_manager.GAME_SCENE)

func _on_delete_save_pressed(save_info: Dictionary):
	show_delete_confirmation(save_info)

func show_delete_confirmation(save_info: Dictionary):
	var dialog_scene = preload("res://scenes/ui/ConfirmationDialog.tscn")
	var dialog = dialog_scene.instantiate()
	dialog.setup(save_info)
	dialog.confirmed.connect(_on_delete_confirmed.bind(save_info))
	dialog.cancelled.connect(_on_delete_cancelled)
	add_child(dialog)

func _on_delete_confirmed(save_info: Dictionary):
	print("Deleting save: ", save_info["name"])
	var success = get_node("/root/SaveSystem").delete_save_file(save_info)
	
	# Always refresh the list after attempting deletion, regardless of return value
	print("Refreshing save list after deletion attempt...")
	populate_save_list()
	
	# Check if any saves remain after refresh
	var has_saves = get_node("/root/SaveSystem").has_save_file()
	print("Has saves after deletion and refresh: ", has_saves)
	
	if not has_saves:
		# No saves left, close the modal and update main menu
		print("No saves remaining, closing modal")
		var main_menu = get_parent()
		if main_menu.has_method("update_continue_button"):
			main_menu.update_continue_button()
		queue_free()
	else:
		print("Save list refreshed successfully")

func format_timestamp(timestamp: String) -> String:
	# Convert ISO timestamp to readable format
	if timestamp.is_empty():
		return "Unknown time"
	
	# Try to parse the timestamp and format it nicely
	var parts = timestamp.split("T")
	if parts.size() >= 2:
		var date_part = parts[0]
		var time_part = parts[1].split(".")[0]  # Remove milliseconds
		return date_part + " " + time_part
	
	return timestamp

func _on_delete_cancelled():
	print("Delete cancelled")

func _on_back_button_pressed():
	queue_free() 
