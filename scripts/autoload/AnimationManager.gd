extends Node

# Animation system for hot dog store idle game
# Uses intentional naming conventions for future maintainability

# Animation squares for visual feedback
var animation_square_1: ColorRect
var animation_square_2: ColorRect

# Store original positions to prevent drift
var original_position_1: Vector2
var original_position_2: Vector2

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
	
	# Create first square (yellow)
	animation_square_1 = ColorRect.new()
	animation_square_1.color = Color(1.0, 1.0, 0.0, 1.0)  # Solid yellow
	animation_square_1.size = Vector2(50, 50)
	animation_square_1.position = Vector2(
		viewport_size.x / 2 - 60,  # Center, slightly left
		viewport_size.y - 120      # Near bottom
	)
	animation_square_1.visible = true  # Make sure it's visible
	animation_square_1.z_index = 100  # Make sure it's on top
	animation_square_1.pivot_offset = Vector2(25, 25)  # Center the pivot for proper scaling
	current_scene.add_child(animation_square_1)  # Add to current scene instead
	original_position_1 = animation_square_1.position  # Store original position
	print("AnimationManager: Created yellow square at position: ", animation_square_1.position)
	
	# Create second square (orange)
	animation_square_2 = ColorRect.new()
	animation_square_2.color = Color(1.0, 0.5, 0.0, 1.0)  # Solid orange
	animation_square_2.size = Vector2(50, 50)
	animation_square_2.position = Vector2(
		viewport_size.x / 2 + 10,  # Center, slightly right
		viewport_size.y - 120      # Near bottom
	)
	animation_square_2.visible = true  # Make sure it's visible
	animation_square_2.z_index = 100  # Make sure it's on top
	animation_square_2.pivot_offset = Vector2(25, 25)  # Center the pivot for proper scaling
	current_scene.add_child(animation_square_2)  # Add to current scene instead
	original_position_2 = animation_square_2.position  # Store original position
	print("AnimationManager: Created orange square at position: ", animation_square_2.position)
	
	print("AnimationManager: Animation squares created at bottom center")

func _on_click_state_changed(is_clicking: bool, is_holding: bool):
	"""Handle click state changes"""
	# If we were holding and now we're not, stop the hold animation
	if not is_holding and (animation_square_1.has_meta("hold_tween") or animation_square_2.has_meta("hold_tween")):
		_animate_hold_complete()

func _on_click_started(click_type: String):
	"""Handle click start events"""
	if click_type == "hold":
		_animate_hold_start()

func _on_click_completed(click_type: String, hot_dogs_produced: int):
	"""Handle click completion events"""
	if click_type == "click":
		_animate_click()  # Animate on click completion since clicks are instant
	# Note: We don't call _animate_hold_complete() for hold actions
	# because holds are continuous and we want the animation to keep looping
	# The hold animation will be stopped when the hold action actually ends

func _on_hot_dogs_produced(amount: int, source: String):
	"""Handle hot dog production events - animate yellow square"""
	print("AnimationManager: Hot dogs produced - animating yellow square")
	_animate_production(animation_square_1)

func _on_hot_dogs_sold(amount: int, value: int):
	"""Handle hot dog sales events - animate orange square"""
	print("AnimationManager: Hot dogs sold - animating orange square")
	_animate_sale(animation_square_2)

func _animate_click():
	"""Animate squares for instant click"""
	if not animation_square_1 or not animation_square_2:
		print("AnimationManager: Cannot animate - squares not found")
		return
	
	print("AnimationManager: Animating click - squares at positions: ", animation_square_1.position, ", ", animation_square_2.position)
	
	# Quick pulse animation for instant clicks (shorter duration, smaller movement)
	_animate_square_pulse(animation_square_1, 0.1)  # Very quick pulse
	_animate_square_pulse(animation_square_2, 0.1)  # Very quick pulse

func _animate_hold_start():
	"""Start hold animation"""
	if not animation_square_1 or not animation_square_2:
		return
	
	print("AnimationManager: Starting hold animation")
	
	# Start continuous hold animations
	_start_continuous_hold_animation(animation_square_1, Vector2(-animation_distance * 0.3, 0))
	_start_continuous_hold_animation(animation_square_2, Vector2(animation_distance * 0.3, 0))

func _animate_hold_complete():
	"""Complete hold animation"""
	print("AnimationManager: Hold animation complete")
	
	# Stop continuous hold animations
	if animation_square_1:
		_stop_continuous_hold_animation(animation_square_1)
	if animation_square_2:
		_stop_continuous_hold_animation(animation_square_2)

func _start_continuous_hold_animation(square: ColorRect, target_offset: Vector2):
	"""Start a continuous hold animation that repeats"""
	if not square:
		return
	
	# Kill any existing hold tweens
	if square.has_meta("hold_tween"):
		var existing_tween = square.get_meta("hold_tween")
		if existing_tween:
			existing_tween.kill()
	
	# Kill any existing pulse tweens
	if square.has_meta("pulse_tween"):
		var existing_pulse_tween = square.get_meta("pulse_tween")
		if existing_pulse_tween:
			existing_pulse_tween.kill()
		square.set_meta("pulse_tween", null)
	
	# Force reset to original state immediately
	square.scale = Vector2(1.0, 1.0)
	
	# Reset to stored original position
	if square == animation_square_1:
		square.position = original_position_1
	elif square == animation_square_2:
		square.position = original_position_2
	
	var tween = create_tween()
	square.set_meta("hold_tween", tween)
	
	# Use stored original position, not current position
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

func _stop_continuous_hold_animation(square: ColorRect):
	"""Stop continuous hold animation and return to original state"""
	if not square:
		return
	
	# Kill the tween
	if square.has_meta("hold_tween"):
		var existing_tween = square.get_meta("hold_tween")
		if existing_tween:
			existing_tween.kill()
		square.set_meta("hold_tween", null)
	
	# Return to original state
	square.scale = Vector2(1.0, 1.0)
	
	# Return to stored original position
	if square == animation_square_1:
		square.position = original_position_1
	elif square == animation_square_2:
		square.position = original_position_2

func _animate_square(square: ColorRect, target_offset: Vector2, duration: float):
	"""Animate a square with movement and scaling"""
	if not square:
		return
	
	# Kill any existing tweens for this square to prevent conflicts
	if square.has_meta("hold_tween"):
		var existing_tween = square.get_meta("hold_tween")
		if existing_tween:
			existing_tween.kill()
	
	var tween = create_tween()
	square.set_meta("hold_tween", tween)  # Store reference to this tween
	
	var original_pos = square.position  # Store original position
	var original_scale = Vector2(1.0, 1.0)  # Always return to original scale
	var target_pos = original_pos + target_offset
	var target_scale = original_scale * animation_scale
	
	# Animate position and scale outward
	tween.parallel().tween_property(square, "position", target_pos, duration)
	tween.parallel().tween_property(square, "scale", target_scale, duration)
	
	# Return to original state
	tween.tween_property(square, "position", original_pos, duration * 0.5)
	tween.parallel().tween_property(square, "scale", original_scale, duration * 0.5)
	
	# Clean up tween reference when done
	tween.finished.connect(func(): square.set_meta("hold_tween", null))

func _animate_square_pulse(square: ColorRect, duration: float):
	"""Animate a square with a quick pulse (scale only, no movement)"""
	if not square:
		return
	
	# Reset to original state immediately to prevent drift
	square.scale = Vector2(1.0, 1.0)
	
	# Kill any existing tweens for this square to prevent conflicts
	if square.has_meta("pulse_tween"):
		var existing_tween = square.get_meta("pulse_tween")
		if existing_tween:
			existing_tween.kill()
	
	var tween = create_tween()
	square.set_meta("pulse_tween", tween)  # Store reference to this tween
	
	var original_scale = Vector2(1.0, 1.0)  # Always return to original scale
	var target_scale = original_scale * 1.3  # Scale up from original
	
	# Quick scale up and down
	tween.tween_property(square, "scale", target_scale, duration * 0.5)
	tween.tween_property(square, "scale", original_scale, duration * 0.5)
	
	# Clean up tween reference when done
	tween.finished.connect(func(): square.set_meta("pulse_tween", null))

func test_animations():
	"""Test animation system"""
	print("AnimationManager: Testing animations")
	_animate_click()

func make_squares_visible():
	"""Make sure squares are visible and add some debug info"""
	if animation_square_1:
		animation_square_1.visible = true
		animation_square_1.color = Color(1.0, 1.0, 0.0, 1.0)  # Solid yellow
		animation_square_1.z_index = 100  # Make sure it's on top
		print("AnimationManager: Made yellow square visible at position: ", animation_square_1.position, " z_index: ", animation_square_1.z_index)
	
	if animation_square_2:
		animation_square_2.visible = true
		animation_square_2.color = Color(1.0, 0.5, 0.0, 1.0)  # Solid orange
		animation_square_2.z_index = 100  # Make sure it's on top
		print("AnimationManager: Made orange square visible at position: ", animation_square_2.position, " z_index: ", animation_square_2.z_index)
	
	# Test hold animation after a delay
	await get_tree().create_timer(1.0).timeout
	_animate_hold_start() 

func _animate_production(square: ColorRect):
	"""Animate yellow square for hot dog production"""
	if not square:
		return
	
	# Kill any existing tweens for this square
	if square.has_meta("production_tween"):
		var existing_tween = square.get_meta("production_tween")
		if existing_tween:
			existing_tween.kill()
	
	# Reset to original state
	square.scale = Vector2(1.0, 1.0)
	if square == animation_square_1:
		square.position = original_position_1
	
	var tween = create_tween()
	square.set_meta("production_tween", tween)
	
	# Production animation: quick outward movement and scale up
	var original_pos = square.position
	var target_pos = original_pos + Vector2(0, -30)  # Move up
	var target_scale = Vector2(1.0, 1.0) * 1.4  # Scale up
	
	# Quick outward animation
	tween.parallel().tween_property(square, "position", target_pos, 0.2)
	tween.parallel().tween_property(square, "scale", target_scale, 0.2)
	
	# Return to original state
	tween.tween_property(square, "position", original_pos, 0.15)
	tween.parallel().tween_property(square, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Clean up tween reference when done
	tween.finished.connect(func(): square.set_meta("production_tween", null))

func _animate_sale(square: ColorRect):
	"""Animate orange square for hot dog sales"""
	if not square:
		return
	
	# Kill any existing tweens for this square
	if square.has_meta("sale_tween"):
		var existing_tween = square.get_meta("sale_tween")
		if existing_tween:
			existing_tween.kill()
	
	# Reset to original state
	square.scale = Vector2(1.0, 1.0)
	if square == animation_square_2:
		square.position = original_position_2
	
	var tween = create_tween()
	square.set_meta("sale_tween", tween)
	
	# Sale animation: quick outward movement and scale up with different timing
	var original_pos = square.position
	var target_pos = original_pos + Vector2(0, -25)  # Move up slightly less
	var target_scale = Vector2(1.0, 1.0) * 1.3  # Scale up slightly less
	
	# Quick outward animation
	tween.parallel().tween_property(square, "position", target_pos, 0.25)
	tween.parallel().tween_property(square, "scale", target_scale, 0.25)
	
	# Return to original state
	tween.tween_property(square, "position", original_pos, 0.2)
	tween.parallel().tween_property(square, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Clean up tween reference when done
	tween.finished.connect(func(): square.set_meta("sale_tween", null))
