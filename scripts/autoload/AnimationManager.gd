extends Node

# Animation system for hot dog store idle game
# Uses intentional naming conventions for future maintainability

# Animation squares for visual feedback
var production_square: ColorRect  # Yellow square for production
var sales_square: ColorRect       # Orange square for sales

# Store original positions to prevent drift
var production_square_original_position: Vector2
var sales_square_original_position: Vector2

# Animation configuration
const ANIMATION_CONFIG = {
	"production": {
		"color": Color(1.0, 1.0, 0.0, 1.0),  # Yellow
		"size": Vector2(50, 50),
		"pulse_scale": 1.3,
		"production_scale": 1.4,
		"production_move_distance": 30,
		"production_duration": 0.2,
		"production_return_duration": 0.15
	},
	"sales": {
		"color": Color(1.0, 0.5, 0.0, 1.0),  # Orange
		"size": Vector2(50, 50),
		"pulse_scale": 1.3,
		"production_scale": 1.3,
		"production_move_distance": 25,
		"production_duration": 0.25,
		"production_return_duration": 0.2
	}
}

# Animation properties
var animation_duration: float = 0.15
var animation_scale: float = 1.5
var animation_distance: float = 50.0

# References to managers
var hot_dog_manager: Node
var click_manager: Node

func _ready():
	print("AnimationManager: Initialized")
	
	# Get references to managers
	hot_dog_manager = get_node("/root/HotDogManager")
	click_manager = get_node("/root/ClickManager")
	
	# Connect to click events
	if click_manager:
		click_manager.click_completed.connect(_on_click_completed)
		click_manager.click_started.connect(_on_click_started)
		click_manager.click_state_changed.connect(_on_click_state_changed)
	
	# Connect to hot dog events
	if hot_dog_manager:
		hot_dog_manager.hot_dogs_produced.connect(_on_hot_dogs_produced)
		hot_dog_manager.hot_dogs_sold.connect(_on_hot_dogs_sold)

func _create_central_animation_squares():
	"""Create the two animation squares at the bottom center of the screen"""
	print("AnimationManager: Creating animation squares")
	
	# Get the current scene to add squares to
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("AnimationManager: No current scene found")
		return
	
	# Get viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	print("AnimationManager: Viewport size: ", viewport_size)
	
	# Create production square (yellow)
	production_square = _create_square(
		ANIMATION_CONFIG.production.color,
		ANIMATION_CONFIG.production.size,
		Vector2(viewport_size.x / 2 - 60, viewport_size.y - 120),
		current_scene
	)
	production_square_original_position = production_square.position
	print("AnimationManager: Created production square at position: ", production_square.position)
	
	# Create sales square (orange)
	sales_square = _create_square(
		ANIMATION_CONFIG.sales.color,
		ANIMATION_CONFIG.sales.size,
		Vector2(viewport_size.x / 2 + 10, viewport_size.y - 120),
		current_scene
	)
	sales_square_original_position = sales_square.position
	print("AnimationManager: Created sales square at position: ", sales_square.position)
	
	print("AnimationManager: Animation squares created at bottom center")

func _create_square(color: Color, size: Vector2, position: Vector2, parent: Node) -> ColorRect:
	"""Helper function to create a square with consistent properties"""
	var square = ColorRect.new()
	square.color = color
	square.size = size
	square.position = position
	square.visible = true
	square.z_index = 100
	square.pivot_offset = size / 2  # Center the pivot for proper scaling
	parent.add_child(square)
	return square

func _on_click_state_changed(is_clicking: bool, is_holding: bool):
	"""Handle click state changes"""
	# If we were holding and now we're not, stop the hold animation
	if not is_holding and production_square.has_meta("hold_tween"):
		_stop_hold_animation()

func _on_click_started(click_type: String):
	"""Handle click start events"""
	if click_type == "hold":
		_start_hold_animation()

func _on_click_completed(click_type: String, hot_dogs_produced: int):
	"""Handle click completion events"""
	if click_type == "click":
		_animate_production_pulse()  # Animate on click completion since clicks are instant
	# Note: We don't call _stop_hold_animation() for hold actions
	# because holds are continuous and we want the animation to keep looping
	# The hold animation will be stopped when the hold action actually ends

func _on_hot_dogs_produced(amount: int, source: String):
	"""Handle hot dog production events - animate production square"""
	print("AnimationManager: Hot dogs produced - animating production square")
	_animate_production_event(production_square, ANIMATION_CONFIG.production)

func _on_hot_dogs_sold(amount: int, value: int):
	"""Handle hot dog sales events - animate sales square"""
	print("AnimationManager: Hot dogs sold - animating sales square")
	_animate_production_event(sales_square, ANIMATION_CONFIG.sales)

func _animate_production_pulse():
	"""Animate production square for instant click"""
	if not production_square:
		print("AnimationManager: Cannot animate - production square not found")
		return
	
	print("AnimationManager: Animating production pulse")
	_animate_pulse(production_square, 0.1, ANIMATION_CONFIG.production.pulse_scale)

func _start_hold_animation():
	"""Start hold animation"""
	if not production_square:
		return
	
	print("AnimationManager: Starting hold animation")
	_start_continuous_animation(production_square, Vector2(-animation_distance * 0.3, 0))

func _stop_hold_animation():
	"""Stop hold animation"""
	print("AnimationManager: Hold animation complete")
	if production_square:
		_stop_continuous_animation(production_square)

func _start_continuous_animation(square: ColorRect, target_offset: Vector2):
	"""Start a continuous animation that repeats"""
	if not square:
		return
	
	# Kill any existing tweens
	_kill_tween(square, "hold_tween")
	_kill_tween(square, "pulse_tween")
	
	# Reset to original state
	_reset_square_state(square)
	
	var tween = create_tween()
	square.set_meta("hold_tween", tween)
	
	# Use stored original position
	var original_pos = square.position
	var original_scale = Vector2(1.0, 1.0)
	var target_pos = original_pos + target_offset
	var target_scale = original_scale * animation_scale
	
	# Create a looping animation
	tween.set_loops()  # Infinite loops
	
	# Animate outward
	tween.tween_property(square, "position", target_pos, animation_duration * 2)
	tween.parallel().tween_property(square, "scale", target_scale, animation_duration * 2)
	
	# Animate back
	tween.tween_property(square, "position", original_pos, animation_duration * 2)
	tween.parallel().tween_property(square, "scale", original_scale, animation_duration * 2)

func _stop_continuous_animation(square: ColorRect):
	"""Stop continuous animation and return to original state"""
	if not square:
		return
	
	_kill_tween(square, "hold_tween")
	_reset_square_state(square)

func _animate_pulse(square: ColorRect, duration: float, scale_factor: float):
	"""Animate a square with a quick pulse (scale only, no movement)"""
	if not square:
		return
	
	# Reset to original state immediately to prevent drift
	square.scale = Vector2(1.0, 1.0)
	
	# Kill any existing pulse tweens
	_kill_tween(square, "pulse_tween")
	
	var tween = create_tween()
	square.set_meta("pulse_tween", tween)
	
	var original_scale = Vector2(1.0, 1.0)
	var target_scale = original_scale * scale_factor
	
	# Quick scale up and down
	tween.tween_property(square, "scale", target_scale, duration * 0.5)
	tween.tween_property(square, "scale", original_scale, duration * 0.5)
	
	# Clean up tween reference when done
	tween.finished.connect(func(): square.set_meta("pulse_tween", null))

func _animate_production_event(square: ColorRect, config: Dictionary):
	"""Animate square for production/sales events"""
	if not square:
		return
	
	# Kill any existing tweens for this square
	_kill_tween(square, "production_tween")
	
	# Reset to original state
	_reset_square_state(square)
	
	var tween = create_tween()
	square.set_meta("production_tween", tween)
	
	# Production animation: quick outward movement and scale up
	var original_pos = square.position
	var target_pos = original_pos + Vector2(0, -config.production_move_distance)
	var target_scale = Vector2(1.0, 1.0) * config.production_scale
	
	# Quick outward animation
	tween.parallel().tween_property(square, "position", target_pos, config.production_duration)
	tween.parallel().tween_property(square, "scale", target_scale, config.production_duration)
	
	# Return to original state
	tween.tween_property(square, "position", original_pos, config.production_return_duration)
	tween.parallel().tween_property(square, "scale", Vector2(1.0, 1.0), config.production_return_duration)
	
	# Clean up tween reference when done
	tween.finished.connect(func(): square.set_meta("production_tween", null))

func _kill_tween(square: ColorRect, tween_name: String):
	"""Helper function to kill a tween and clean up metadata"""
	if square.has_meta(tween_name):
		var existing_tween = square.get_meta(tween_name)
		if existing_tween:
			existing_tween.kill()
		square.set_meta(tween_name, null)

func _reset_square_state(square: ColorRect):
	"""Helper function to reset square to original state"""
	square.scale = Vector2(1.0, 1.0)
	
	# Return to stored original position
	if square == production_square:
		square.position = production_square_original_position
	elif square == sales_square:
		square.position = sales_square_original_position
