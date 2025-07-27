extends Button

# Currency gain button with click and hold functionality
# Uses intentional naming conventions for future maintainability

var click_manager: Node
var currency_manager: Node

# Visual state tracking
var is_pressed: bool = false
var is_held: bool = false

# Hold detection variables
var _hold_timer_started: bool = false
var _hold_start_time: Dictionary

# Button states
enum ButtonState {IDLE, CLICKED, HELD}
var current_state: ButtonState = ButtonState.IDLE

func _ready():
	print("CurrencyGainButton: Initialized")
	
	# Get references to managers
	click_manager = get_node("/root/ClickManager")
	currency_manager = get_node("/root/CurrencyManager")
	
	# Connect button signals
	pressed.connect(_on_button_pressed)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	# Connect to click manager for state updates
	if click_manager:
		click_manager.click_state_changed.connect(_on_click_state_changed)
		click_manager.click_completed.connect(_on_click_completed)
	
	# Connect to viewport size changes for responsive sizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_responsive_layout()
	
	# Set initial visual state
	_update_visual_state()

func _on_viewport_size_changed():
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive size (like CSS vw/vh units)
	var width_percent = viewport_size.x * 0.15  # 15% of viewport width
	var height_percent = viewport_size.y * 0.08  # 8% of viewport height
	
	var responsive_width = max(150, min(width_percent, 300))  # 150px to 300px
	var responsive_height = max(60, min(height_percent, 120))  # 60px to 120px
	
	offset_left = -responsive_width / 2
	offset_right = responsive_width / 2
	offset_top = -responsive_height / 2
	offset_bottom = responsive_height / 2
	
	# Calculate responsive font size
	var font_size_percent = viewport_size.x * 0.015  # 1.5% of viewport width
	var responsive_font_size = max(16, min(font_size_percent, 32))  # 16px to 32px
	add_theme_font_size_override("font_size", responsive_font_size)
	
	print("CurrencyGainButton: Size updated to ", Vector2(responsive_width, responsive_height), " font: ", responsive_font_size)

func _on_button_pressed():
	"""Handle button press (single click)"""
	print("CurrencyGainButton: Button pressed")
	if click_manager and not click_manager.is_action_in_progress():
		# Only start click action if we're not already holding
		if not is_held:
			click_manager.start_click_action()
			current_state = ButtonState.CLICKED
			_update_visual_state()

func _on_button_down():
	"""Handle button down (start of hold)"""
	print("CurrencyGainButton: Button down")
	is_pressed = true
	# Don't start hold action immediately - wait for button_up to determine if it was a click or hold

func _on_button_up():
	"""Handle button up (end of press)"""
	print("CurrencyGainButton: Button up")
	is_pressed = false
	
	# Reset hold timer
	_hold_timer_started = false
	
	# If we were holding and button is released, stop the hold action
	if is_held and click_manager:
		click_manager.stop_click_action()
		is_held = false
		current_state = ButtonState.IDLE
		_update_visual_state()

func _input(event):
	"""Handle input for hold detection"""
	if not is_pressed:
		return
	
	# Check if mouse is still over the button
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var button_rect = get_global_rect()
		
		# If mouse leaves button while pressed, stop any actions
		if not button_rect.has_point(mouse_pos):
			if click_manager:
				click_manager.stop_click_action()
			is_held = false
			current_state = ButtonState.IDLE
			_update_visual_state()
			return
	
	# Start hold action if button has been pressed for a short time
	if is_pressed and not is_held and click_manager and not click_manager.is_action_in_progress():
		# Use a timer to detect hold vs click
		await get_tree().create_timer(0.1).timeout  # 100ms delay
		if is_pressed and click_manager and not click_manager.is_action_in_progress():
			print("CurrencyGainButton: Starting hold action")
			click_manager.start_hold_action()
			is_held = true
			current_state = ButtonState.HELD
			_update_visual_state()

func _process(delta):
	"""Process hold detection without requiring mouse movement"""
	if is_pressed and not is_held and click_manager and not click_manager.is_action_in_progress():
		# Check if we've been holding for a short time
		if not _hold_timer_started:
			_hold_timer_started = true
			_hold_start_time = Time.get_time_dict_from_system()
		
		var current_time = Time.get_time_dict_from_system()
		var hold_duration = (current_time.hour - _hold_start_time.hour) * 3600 + \
						   (current_time.minute - _hold_start_time.minute) * 60 + \
						   (current_time.second - _hold_start_time.second) + \
						   (current_time.msec - _hold_start_time.msec) / 1000.0
		
		if hold_duration >= 0.1:  # 100ms hold threshold
			print("CurrencyGainButton: Starting hold action (process)")
			click_manager.start_hold_action()
			is_held = true
			current_state = ButtonState.HELD
			_update_visual_state()
			_hold_timer_started = false

func _on_click_state_changed(is_clicking: bool, is_holding: bool):
	"""Update button state based on click manager state"""
	if not is_clicking and not is_holding:
		current_state = ButtonState.IDLE
		is_held = false
		_update_visual_state()

func _on_click_completed(click_type: String, currency_gained: int):
	"""Handle click completion"""
	print("CurrencyGainButton: Click completed - ", click_type, " gained ", currency_gained, " currency")
	current_state = ButtonState.IDLE
	is_held = false
	_update_visual_state()

func _update_visual_state():
	"""Update button appearance based on current state"""
	match current_state:
		ButtonState.IDLE:
			# Normal state
			modulate = Color.WHITE
			text = "Gain Currency"
			print("CurrencyGainButton: Visual state - IDLE")
		ButtonState.CLICKED:
			# Clicked state
			modulate = Color(0.8, 1.0, 0.8, 1.0)  # Light green
			text = "Clicking..."
			print("CurrencyGainButton: Visual state - CLICKED")
		ButtonState.HELD:
			# Held state
			modulate = Color(1.0, 0.8, 0.6, 1.0)  # Light orange
			text = "Holding..."
			print("CurrencyGainButton: Visual state - HELD")

func get_current_state() -> ButtonState:
	"""Get current button state"""
	return current_state

func is_button_active() -> bool:
	"""Check if button is currently active (clicking or holding)"""
	return current_state != ButtonState.IDLE 