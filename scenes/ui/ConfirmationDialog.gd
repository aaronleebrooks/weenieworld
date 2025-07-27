extends Control

@onready var no_button = $DialogPanel/VBoxContainer/ButtonContainer/NoButton
@onready var yes_button = $DialogPanel/VBoxContainer/ButtonContainer/YesButton
@onready var dialog_panel = $DialogPanel

signal confirmed()
signal cancelled()

var save_info: Dictionary = {}
var is_closing: bool = false

# Responsive modal properties
var min_width: float = 300.0
var min_height: float = 200.0
var max_width_percent: float = 0.8
var max_height_percent: float = 0.8

func _ready():
	print("DEBUG: ConfirmationDialog: _ready() called")
	
	# Add to group for tracking
	add_to_group("confirmation_dialogs")
	
	# Add dialog panel to group for tracking
	if dialog_panel:
		dialog_panel.add_to_group("dialog_panels")
		print("DEBUG: Dialog panel added to dialog_panels group")
		
		# Set panel background color to ensure it's opaque
		dialog_panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
		var style = dialog_panel.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			style.bg_color = Color(0.2, 0.2, 0.2, 1.0)  # Dark gray, fully opaque
			print("DEBUG: Dialog panel background color set")
	
	# Ensure this dialog is on top of other UI elements
	z_index = 1000
	
	# Make sure this dialog can receive input and blocks input to background
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Ensure the dialog is visible and properly positioned
	visible = true
	
	# Connect button signals with null checks
	if no_button:
		no_button.pressed.connect(_on_no_pressed)
		print("DEBUG: No button signal connected")
	else:
		print("ERROR: No button not found!")
		
	if yes_button:
		yes_button.pressed.connect(_on_yes_pressed)
		print("DEBUG: Yes button signal connected")
	else:
		print("ERROR: Yes button not found!")
	
	# Connect to viewport size changes using native event system
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial size update
	_update_modal_size()
	
	# Style the buttons
	if no_button:
		no_button.add_theme_color_override("font_color", Color.WHITE)
	if yes_button:
		yes_button.add_theme_color_override("font_color", Color.RED)
	
	# Add spacing between buttons
	var button_container = $DialogPanel/VBoxContainer/ButtonContainer
	if button_container:
		button_container.add_theme_constant_override("separation", 20)
		print("DEBUG: Button container spacing set")
	else:
		print("ERROR: Button container not found!")
	
	# Set focus to No button (primary action)
	if no_button:
		no_button.grab_focus()
		print("DEBUG: Focus set to No button")
	
	print("DEBUG: ConfirmationDialog: _ready() completed")
	print("DEBUG: ConfirmationDialog: z_index = ", z_index)
	print("DEBUG: ConfirmationDialog: mouse_filter = ", mouse_filter)
	print("DEBUG: ConfirmationDialog: visible = ", visible)
	print("DEBUG: ConfirmationDialog: global_position = ", global_position)
	print("DEBUG: ConfirmationDialog: size = ", size)
	if dialog_panel:
		print("DEBUG: Dialog panel position = ", dialog_panel.global_position)
		print("DEBUG: Dialog panel size = ", dialog_panel.size)

func _on_viewport_size_changed():
	print("ConfirmationDialog: Viewport size changed")
	_update_modal_size()

func _update_modal_size():
	var viewport_size = get_viewport().get_visible_rect().size
	print("DEBUG: ConfirmationDialog: Viewport size = ", viewport_size)
	
	# Use percentage-based sizing (like CSS vw/vh units)
	var font_size_percent = viewport_size.x * 0.018  # 1.8% of viewport width
	var button_height_percent = viewport_size.y * 0.05  # 5% of viewport height
	
	# Set reasonable bounds
	var responsive_font_size = max(12, min(font_size_percent, 40))  # 12px to 40px
	var button_height = max(35, min(button_height_percent, 80))  # 35px to 80px
	
	print("DEBUG: ConfirmationDialog: Font size = ", responsive_font_size, "px (", font_size_percent, "px raw), Button height = ", button_height, "px (", button_height_percent, "px raw)")
	
	# Update panel size using percentage-based approach
	var target_width = viewport_size.x * 0.4  # 40% of viewport width
	var target_height = viewport_size.y * 0.3  # 30% of viewport height
	
	# Ensure minimum size
	target_width = max(target_width, 300)
	target_height = max(target_height, 200)
	
	print("DEBUG: ConfirmationDialog: Target size = ", Vector2(target_width, target_height))
	
	if dialog_panel:
		print("DEBUG: ConfirmationDialog: Updating panel size")
		dialog_panel.offset_left = -target_width / 2
		dialog_panel.offset_top = -target_height / 2
		dialog_panel.offset_right = target_width / 2
		dialog_panel.offset_bottom = target_height / 2
		
		# Update title font size
		var title = dialog_panel.get_node_or_null("VBoxContainer/Title")
		if title:
			title.add_theme_font_size_override("font_size", responsive_font_size * 1.2)  # Title 20% larger
			print("DEBUG: ConfirmationDialog: Title font size set to ", responsive_font_size * 1.2)
		
		# Update message font size
		var message = dialog_panel.get_node_or_null("VBoxContainer/Message")
		if message:
			message.add_theme_font_size_override("font_size", responsive_font_size)
			print("DEBUG: ConfirmationDialog: Message font size set to ", responsive_font_size)
		
		# Update button font sizes and sizes
		if no_button:
			no_button.custom_minimum_size = Vector2(0, button_height)
			no_button.add_theme_font_size_override("font_size", responsive_font_size)
		
		if yes_button:
			yes_button.custom_minimum_size = Vector2(0, button_height)
			yes_button.add_theme_font_size_override("font_size", responsive_font_size)
		
		print("DEBUG: ConfirmationDialog: Panel updated with percentage-based sizing")
	else:
		print("DEBUG: ConfirmationDialog: No dialog_panel found")

func setup(save_data: Dictionary):
	save_info = save_data

func _on_no_pressed():
	print("DEBUG: ConfirmationDialog: No button pressed")
	if is_closing:
		print("DEBUG: ConfirmationDialog: Already closing, ignoring")
		return
	is_closing = true
	emit_signal("cancelled")
	queue_free()

func _on_yes_pressed():
	print("DEBUG: ConfirmationDialog: Yes button pressed")
	if is_closing:
		print("DEBUG: ConfirmationDialog: Already closing, ignoring")
		return
	is_closing = true
	emit_signal("confirmed")
	queue_free()

func _input(event):
	# Handle escape key to cancel
	if event.is_action_pressed("ui_cancel"):
		print("DEBUG: ConfirmationDialog: Escape key pressed")
		_on_no_pressed()

func _exit_tree():
	"""Ensure cleanup when the dialog is removed from the scene tree"""
	print("DEBUG: ConfirmationDialog: _exit_tree() called")
	is_closing = true
	
	# Remove from group
	remove_from_group("confirmation_dialogs")
	print("DEBUG: ConfirmationDialog: Removed from confirmation_dialogs group") 
