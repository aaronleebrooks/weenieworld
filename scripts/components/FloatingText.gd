extends Control

# Floating text component for showing currency gains
# Uses intentional naming conventions for future maintainability

@onready var label = $Label

var fade_duration: float = 1.0
var move_distance: float = 50.0
var fade_timer: Timer

func _ready():
	# Setup fade timer
	fade_timer = Timer.new()
	fade_timer.one_shot = true
	fade_timer.timeout.connect(_on_fade_complete)
	add_child(fade_timer)
	
	# Start hidden
	visible = false

func show_currency_gain(amount: int, position: Vector2):
	"""Show floating text for currency gain"""
	# Set text
	label.text = "+%d" % amount
	
	# Position the text
	global_position = position
	
	# Reset appearance
	modulate = Color.WHITE
	visible = true
	
	# Start fade animation
	_start_fade_animation()

func _start_fade_animation():
	"""Start the fade out and move up animation"""
	# Create tween for smooth animation
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), fade_duration)
	
	# Move up
	var target_position = global_position + Vector2(0, -move_distance)
	tween.tween_property(self, "global_position", target_position, fade_duration)
	
	# Start timer to hide when done
	fade_timer.start(fade_duration)

func _on_fade_complete():
	"""Hide the floating text when fade is complete"""
	visible = false 