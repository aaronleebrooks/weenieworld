extends Control

@onready var no_button = $DialogPanel/ButtonContainer/NoButton
@onready var yes_button = $DialogPanel/ButtonContainer/YesButton
@onready var dialog_panel = $DialogPanel

signal confirmed()
signal cancelled()

var save_info: Dictionary = {}

# Responsive modal properties
var min_width: float = 300.0
var min_height: float = 200.0
var max_width_percent: float = 0.8
var max_height_percent: float = 0.8

func _ready():
	print("ConfirmationDialog: _ready() called")
	no_button.pressed.connect(_on_no_pressed)
	yes_button.pressed.connect(_on_yes_pressed)
	
	# Connect to viewport size changes using native event system
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial size update
	_update_modal_size()
	
	# Style the buttons
	no_button.add_theme_color_override("font_color", Color.WHITE)
	yes_button.add_theme_color_override("font_color", Color.RED)
	
	# Add spacing between buttons
	var button_container = $DialogPanel/ButtonContainer
	button_container.add_theme_constant_override("separation", 20)
	
	# Set focus to No button (primary action)
	no_button.grab_focus()

func _on_viewport_size_changed():
	print("ConfirmationDialog: Viewport size changed")
	_update_modal_size()

func _update_modal_size():
	var viewport_size = get_viewport().get_visible_rect().size
	print("ConfirmationDialog: Viewport size = ", viewport_size)
	
	var target_width = min(viewport_size.x * max_width_percent, viewport_size.x - 100)
	var target_height = min(viewport_size.y * max_height_percent, viewport_size.y - 100)
	
	# Ensure minimum size
	target_width = max(target_width, min_width)
	target_height = max(target_height, min_height)
	
	print("ConfirmationDialog: Target size = ", Vector2(target_width, target_height))
	
	if dialog_panel:
		print("ConfirmationDialog: Updating panel size")
		dialog_panel.offset_left = -target_width / 2
		dialog_panel.offset_top = -target_height / 2
		dialog_panel.offset_right = target_width / 2
		dialog_panel.offset_bottom = target_height / 2
		print("ConfirmationDialog: Panel offsets set to ", Vector4(dialog_panel.offset_left, dialog_panel.offset_top, dialog_panel.offset_right, dialog_panel.offset_bottom))
	else:
		print("ConfirmationDialog: No dialog_panel found")
	
	# Style the buttons
	no_button.add_theme_color_override("font_color", Color.WHITE)
	yes_button.add_theme_color_override("font_color", Color.RED)
	
	# Add spacing between buttons
	var button_container = $DialogPanel/ButtonContainer
	button_container.add_theme_constant_override("separation", 20)
	
	# Set focus to No button (primary action)
	no_button.grab_focus()

func setup(save_data: Dictionary):
	save_info = save_data

func _on_no_pressed():
	emit_signal("cancelled")
	queue_free()

func _on_yes_pressed():
	emit_signal("confirmed")
	queue_free()

func _input(event):
	# Handle escape key to cancel
	if event.is_action_pressed("ui_cancel"):
		_on_no_pressed() 