extends Node

# Animation system autoload for managing wireframe animations
# Uses intentional naming conventions for future maintainability

# Animation configuration
var click_animation_duration: float = 0.15  # Quicker for clicks
var hold_animation_duration: float = 0.3   # Same as progress bar

# References to other managers
var currency_manager: Node
var click_manager: Node

# Central animation squares
var animation_squares: Array[ColorRect] = []
var animation_container: Control

func _ready():
	print("AnimationManager: Initialized")
	
	# Get references to other managers
	currency_manager = get_node("/root/CurrencyManager")
	click_manager = get_node("/root/ClickManager")
	
	# Connect to currency events for automatic animations
	if currency_manager:
		currency_manager.currency_gained.connect(_on_currency_gained)
	
	# Connect to click manager for hold progress
	if click_manager:
		click_manager.click_progress_updated.connect(_on_click_progress_updated)
	
	# Wait for the game scene to be ready before creating squares
	# We'll create them when the game scene loads

func _create_central_animation_squares():
	"""
	Create two animation squares positioned at the bottom center of the screen.
	
	The squares are used for visual feedback during click and hold actions.
	They are positioned 100 pixels from the bottom edge to avoid overlapping
	with UI elements like buttons and text.
	"""
	# Clear any existing squares first
	_clear_animation_squares()
	
	# Only create squares if we're in the game scene
	var current_scene = get_tree().current_scene
	if not current_scene or current_scene.name != "Game":
		print("AnimationManager: Not in game scene, skipping square creation")
		return
	
	# Find the HelloWorldLabel for reference (used for fallback positioning)
	var hello_label = current_scene.get_node_or_null("HelloWorldLabel")
	
	# Calculate bottom center position (100 pixels from bottom edge)
	var viewport_size = get_viewport().get_visible_rect().size
	var bottom_center = Vector2(viewport_size.x / 2, viewport_size.y - 100)
	
	# Create left square (yellow)
	var square1 = ColorRect.new()
	square1.size = Vector2(30, 30)
	square1.position = bottom_center + Vector2(-40, 0)  # 40 pixels left of center
	square1.color = Color.YELLOW
	
	# Create right square (orange)
	var square2 = ColorRect.new()
	square2.size = Vector2(30, 30)
	square2.position = bottom_center + Vector2(10, 0)   # 10 pixels right of center
	square2.color = Color.ORANGE
	
	# Store references and add to scene
	animation_squares.append(square1)
	animation_squares.append(square2)
	current_scene.add_child(square1)
	current_scene.add_child(square2)
	
	# Store reference for potential future use
	animation_container = hello_label
	
	print("AnimationManager: Created animation squares at bottom center")

func _clear_animation_squares():
	"""Clear existing animation squares"""
	if animation_container and is_instance_valid(animation_container):
		animation_container.queue_free()
	animation_container = null
	animation_squares.clear()

func _on_currency_gained(amount: int, source: String):
	"""Trigger animation when currency is earned"""
	if source == "click":
		_animate_squares_click()
	elif source == "hold":
		# Hold animations are handled by progress updates
		pass

func _on_click_progress_updated(progress: float, click_type: String):
	"""Handle click progress updates for hold animations"""
	if click_type == "hold" and progress > 0:
		_animate_squares_hold(progress)

func _animate_squares_click():
	"""Animate squares quickly for click actions"""
	if animation_squares.size() < 2:
		return
	
	var square1 = animation_squares[0]
	var square2 = animation_squares[1]
	
	# Safety check for freed objects
	if not is_instance_valid(square1) or not is_instance_valid(square2):
		print("AnimationManager: Squares are not valid, recreating...")
		_create_central_animation_squares()
		return
	
	# Create quick animation
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Get reference position from bottom center
	var viewport_size = get_viewport().get_visible_rect().size
	var reference_pos = Vector2(viewport_size.x / 2, viewport_size.y - 100)  # Bottom center
	
	# Move squares outward quickly (more dramatic movement)
	tween.tween_property(square1, "position:x", reference_pos.x - 80, click_animation_duration)
	tween.tween_property(square2, "position:x", reference_pos.x + 50, click_animation_duration)
	
	# Scale up more noticeably
	tween.tween_property(square1, "scale", Vector2(1.5, 1.5), click_animation_duration)
	tween.tween_property(square2, "scale", Vector2(1.5, 1.5), click_animation_duration)
	
	# Return to original position
	tween.tween_property(square1, "position:x", reference_pos.x - 40, click_animation_duration)
	tween.tween_property(square2, "position:x", reference_pos.x + 10, click_animation_duration)
	tween.tween_property(square1, "scale", Vector2(1.0, 1.0), click_animation_duration)
	tween.tween_property(square2, "scale", Vector2(1.0, 1.0), click_animation_duration)
	
	print("AnimationManager: Click animation triggered")

func _animate_squares_hold(progress: float):
	"""Animate squares based on hold progress"""
	if animation_squares.size() < 2:
		return
	
	var square1 = animation_squares[0]
	var square2 = animation_squares[1]
	
	# Safety check for freed objects
	if not is_instance_valid(square1) or not is_instance_valid(square2):
		print("AnimationManager: Squares are not valid, recreating...")
		_create_central_animation_squares()
		return
	
	# Get reference position from bottom center
	var viewport_size = get_viewport().get_visible_rect().size
	var reference_pos = Vector2(viewport_size.x / 2, viewport_size.y - 100)  # Bottom center
	
	# Calculate movement based on progress (0.0 to 1.0)
	var max_movement = 50.0
	var current_movement = max_movement * progress
	
	# Move squares outward based on progress
	square1.position.x = reference_pos.x - 40 - current_movement
	square2.position.x = reference_pos.x + 10 + current_movement
	
	# Scale based on progress
	var scale_factor = 1.0 + (0.3 * progress)
	square1.scale = Vector2(scale_factor, scale_factor)
	square2.scale = Vector2(scale_factor, scale_factor)
	
	# Reset when progress is complete
	if progress >= 1.0:
		_reset_squares_position()

func _reset_squares_position():
	"""Reset squares to their original position"""
	if animation_squares.size() < 2:
		return
	
	var square1 = animation_squares[0]
	var square2 = animation_squares[1]
	
	# Safety check for freed objects
	if not is_instance_valid(square1) or not is_instance_valid(square2):
		print("AnimationManager: Squares are not valid, recreating...")
		_create_central_animation_squares()
		return
	
	# Get reference position from bottom center
	var viewport_size = get_viewport().get_visible_rect().size
	var reference_pos = Vector2(viewport_size.x / 2, viewport_size.y - 100)  # Bottom center
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(square1, "position:x", reference_pos.x - 40, 0.1)
	tween.tween_property(square2, "position:x", reference_pos.x + 10, 0.1)
	tween.tween_property(square1, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(square2, "scale", Vector2(1.0, 1.0), 0.1)

func test_animations():
	"""Test function to manually trigger animations"""
	print("AnimationManager: Testing animations...")
	_animate_squares_click() 
