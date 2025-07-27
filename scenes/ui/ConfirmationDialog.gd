extends Control

@onready var no_button = $DialogPanel/ButtonContainer/NoButton
@onready var yes_button = $DialogPanel/ButtonContainer/YesButton

signal confirmed()
signal cancelled()

var save_info: Dictionary

func _ready():
	no_button.pressed.connect(_on_no_pressed)
	yes_button.pressed.connect(_on_yes_pressed)
	
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