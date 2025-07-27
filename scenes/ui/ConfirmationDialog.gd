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
	
	# Use percentage-based sizing (like CSS vw/vh units)
	var font_size_percent = viewport_size.x * 0.018  # 1.8% of viewport width
	var button_height_percent = viewport_size.y * 0.05  # 5% of viewport height
	
	# Set reasonable bounds
	var responsive_font_size = max(12, min(font_size_percent, 40))  # 12px to 40px
	var button_height = max(35, min(button_height_percent, 80))  # 35px to 80px
	
	print("ConfirmationDialog: Font size = ", responsive_font_size, "px (", font_size_percent, "px raw), Button height = ", button_height, "px (", button_height_percent, "px raw)")
	
	# Update panel size using percentage-based approach
	var target_width = viewport_size.x * 0.4  # 40% of viewport width
	var target_height = viewport_size.y * 0.3  # 30% of viewport height
	
	# Ensure minimum size
	target_width = max(target_width, 300)
	target_height = max(target_height, 200)
	
	print("ConfirmationDialog: Target size = ", Vector2(target_width, target_height))
	
	if dialog_panel:
		print("ConfirmationDialog: Updating panel size")
		dialog_panel.offset_left = -target_width / 2
		dialog_panel.offset_top = -target_height / 2
		dialog_panel.offset_right = target_width / 2
		dialog_panel.offset_bottom = target_height / 2
		
		# Update title font size
		var title = dialog_panel.get_node_or_null("Title")
		if title:
			title.add_theme_font_size_override("font_size", responsive_font_size * 1.2)  # Title 20% larger
		
		# Update message font size
		var message = dialog_panel.get_node_or_null("Message")
		if message:
			message.add_theme_font_size_override("font_size", responsive_font_size)
		
		# Update button font sizes and sizes
		if no_button:
			no_button.custom_minimum_size = Vector2(0, button_height)
			no_button.add_theme_font_size_override("font_size", responsive_font_size)
		
		if yes_button:
			yes_button.custom_minimum_size = Vector2(0, button_height)
			yes_button.add_theme_font_size_override("font_size", responsive_font_size)
		
		print("ConfirmationDialog: Panel updated with percentage-based sizing")
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