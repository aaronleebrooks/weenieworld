extends Control

# Truck Naming Modal for "Alien Hot Dog Food Truck"
# Handles truck name input and validation

signal truck_name_confirmed(truck_name: String)
signal truck_naming_cancelled()

@onready var name_input = $ModalContainer/NameInput
@onready var confirm_button = $ModalContainer/ButtonContainer/ConfirmButton
@onready var cancel_button = $ModalContainer/ButtonContainer/CancelButton
@onready var title = $ModalContainer/Title
@onready var description = $ModalContainer/Description

# Validation settings
const MIN_NAME_LENGTH = 3
const MAX_NAME_LENGTH = 20

func _ready():
	print("TruckNamingModal: Initialized")
	
	# Connect button signals
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Connect input signals
	name_input.text_changed.connect(_on_name_input_changed)
	name_input.text_submitted.connect(_on_name_submitted)
	
	# Set initial state
	confirm_button.disabled = true
	name_input.grab_focus()
	
	# Update responsive layout
	_update_responsive_layout()
	get_viewport().size_changed.connect(_update_responsive_layout)

func _update_responsive_layout():
	"""Update layout for responsive design"""
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive font sizes
	var title_font_size = max(24, min(viewport_size.x * 0.03, 48))
	var body_font_size = max(16, min(viewport_size.x * 0.02, 32))
	var button_font_size = max(14, min(viewport_size.x * 0.018, 28))
	
	# Update font sizes
	title.add_theme_font_size_override("font_size", title_font_size)
	description.add_theme_font_size_override("font_size", body_font_size)
	name_input.add_theme_font_size_override("font_size", body_font_size)
	confirm_button.add_theme_font_size_override("font_size", button_font_size)
	cancel_button.add_theme_font_size_override("font_size", button_font_size)
	
	# Update modal size based on viewport
	var modal_width = max(400, min(viewport_size.x * 0.8, 600))
	var modal_height = max(300, min(viewport_size.y * 0.6, 400))
	
	var modal_container = $ModalContainer
	modal_container.offset_left = -modal_width / 2
	modal_container.offset_top = -modal_height / 2
	modal_container.offset_right = modal_width / 2
	modal_container.offset_bottom = modal_height / 2

func _on_name_input_changed(new_text: String):
	"""Handle name input changes and validation"""
	var is_valid = _validate_truck_name(new_text)
	confirm_button.disabled = not is_valid
	
	# Update button text based on validation
	if is_valid:
		confirm_button.text = "Start Game"
		confirm_button.modulate = Color.WHITE
	else:
		confirm_button.text = "Enter Valid Name"
		confirm_button.modulate = Color.GRAY

func _on_name_submitted(new_text: String):
	"""Handle Enter key press in name input"""
	if _validate_truck_name(new_text):
		_on_confirm_pressed()

func _validate_truck_name(name: String) -> bool:
	"""Validate truck name according to rules"""
	# Check length
	if name.length() < MIN_NAME_LENGTH or name.length() > MAX_NAME_LENGTH:
		return false
	
	# Check if name is just whitespace
	if name.strip_edges().is_empty():
		return false
	
	# Allow alphanumeric characters, spaces, and common punctuation
	var valid_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'.,!?"
	
	for char in name:
		if not valid_chars.contains(char):
			return false
	
	return true

func _on_confirm_pressed():
	"""Handle confirm button press"""
	var truck_name = name_input.text.strip_edges()
	
	if _validate_truck_name(truck_name):
		print("TruckNamingModal: Showing confirmation modal for: ", truck_name)
		_show_confirmation_modal(truck_name)
	else:
		print("TruckNamingModal: Invalid truck name: ", truck_name)

func _show_confirmation_modal(truck_name: String):
	"""Show the confirmation modal with the truck name"""
	var confirmation_scene = preload("res://scenes/ui/TruckConfirmationModal.tscn")
	var confirmation_modal = confirmation_scene.instantiate()
	add_child(confirmation_modal)
	
	# Set the truck name in the confirmation modal
	confirmation_modal.set_truck_name(truck_name)
	
	# Connect confirmation modal signals
	confirmation_modal.truck_confirmed.connect(_on_confirmation_confirmed)
	confirmation_modal.confirmation_cancelled.connect(_on_confirmation_cancelled)

func _on_confirmation_confirmed(truck_name: String):
	"""Handle confirmation modal confirmation"""
	print("TruckNamingModal: Confirmation confirmed, starting game with: ", truck_name)
	emit_signal("truck_name_confirmed", truck_name)
	queue_free()

func _on_confirmation_cancelled():
	"""Handle confirmation modal cancellation"""
	print("TruckNamingModal: Confirmation cancelled, returning to naming")
	# The confirmation modal will be automatically removed
	# and we'll return to the naming modal

func _on_cancel_pressed():
	"""Handle cancel button press"""
	print("TruckNamingModal: Truck naming cancelled")
	emit_signal("truck_naming_cancelled")
	queue_free()

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if _validate_truck_name(name_input.text.strip_edges()):
			_on_confirm_pressed()

# Public methods
func set_default_name(name: String):
	"""Set a default name in the input field"""
	name_input.text = name
	_on_name_input_changed(name)

func get_current_name() -> String:
	"""Get the current name from the input field"""
	return name_input.text.strip_edges() 