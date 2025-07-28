extends Control

signal exit_confirmed()
signal exit_cancelled()

@onready var title = $ModalContainer/Title
@onready var description = $ModalContainer/Description
@onready var confirm_button = $ModalContainer/ButtonContainer/ConfirmButton
@onready var cancel_button = $ModalContainer/ButtonContainer/CancelButton

func _ready():
	"""Initialize the exit confirmation modal"""
	# Connect button signals
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Set up responsive design
	_update_responsive_layout()
	get_viewport().size_changed.connect(_update_responsive_layout)

func _update_responsive_layout():
	"""Update layout for responsive design"""
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive font sizes
	var title_font_size = max(20, min(viewport_size.x * 0.025, 40))
	var body_font_size = max(16, min(viewport_size.x * 0.02, 32))
	var button_font_size = max(14, min(viewport_size.x * 0.018, 28))
	
	# Update font sizes
	title.add_theme_font_size_override("font_size", title_font_size)
	description.add_theme_font_size_override("font_size", body_font_size)
	confirm_button.add_theme_font_size_override("font_size", button_font_size)
	cancel_button.add_theme_font_size_override("font_size", button_font_size)
	
	# Update modal size based on viewport
	var modal_width = max(500, min(viewport_size.x * 0.8, 700))
	var modal_height = max(240, min(viewport_size.y * 0.5, 300))
	
	var modal_container = $ModalContainer
	modal_container.offset_left = -modal_width / 2
	modal_container.offset_top = -modal_height / 2
	modal_container.offset_right = modal_width / 2
	modal_container.offset_bottom = modal_height / 2

func _on_confirm_pressed():
	"""Handle confirm button press"""
	print("ExitConfirmationModal: Exit confirmed")
	emit_signal("exit_confirmed")
	queue_free()

func _on_cancel_pressed():
	"""Handle cancel button press"""
	print("ExitConfirmationModal: Exit cancelled")
	emit_signal("exit_cancelled")
	queue_free()

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		_on_confirm_pressed() 