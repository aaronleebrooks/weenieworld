extends Control

# Floating text component for showing hot dog gains and currency gains
# Uses intentional naming conventions for future maintainability

@onready var label = $Label

var fade_duration: float = 2.0
var move_distance: float = 80.0
var fade_timer: Timer

func _ready():
	# Setup fade timer
	fade_timer = Timer.new()
	fade_timer.one_shot = true
	fade_timer.timeout.connect(_on_fade_complete)
	add_child(fade_timer)
	
	# Start hidden
	visible = false

func show_hot_dog_gain(amount: int, position: Vector2):
	"""Show floating text for hot dog gain"""
	if not label:
		print("ERROR: FloatingText: Label node is null!")
		return
	
	# Set text and color
	label.text = "+%d" % amount
	label.modulate = Color(0.8, 0.6, 0.2, 1.0)  # Orange for hot dogs
	
	# Position the text (local position within parent)
	position = position
	
	# Reset appearance
	modulate = Color.WHITE
	visible = true
	
	# Start fade animation
	_start_fade_animation()

func show_currency_gain(amount: int, position: Vector2):
	"""Show floating text for currency gain"""
	# Set text and color
	label.text = "+$%d" % amount
	label.modulate = Color(0.2, 0.8, 0.2, 1.0)  # Green for currency
	
	# Position the text (local position within parent)
	position = position
	
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
	
	# Move up (local position within parent)
	var target_position = position + Vector2(0, -move_distance)
	tween.tween_property(self, "position", target_position, fade_duration)
	
	# Start timer to hide when done
	fade_timer.start(fade_duration)
	
	# Connect tween completion to hide
	tween.finished.connect(_on_fade_complete)

func _on_fade_complete():
	"""Hide the floating text when fade is complete"""
	visible = false
	
	# Return to pool if we have a reference to the manager
	var floating_text_manager = get_node_or_null("/root/FloatingTextManager")
	if floating_text_manager:
		floating_text_manager._return_floating_text(self) 