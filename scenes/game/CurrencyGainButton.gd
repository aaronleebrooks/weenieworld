extends Button

# Currency gain button with click and hold functionality
# Uses intentional naming conventions for future maintainability

var click_manager: Node
var currency_manager: Node

# Visual state tracking
var is_pressed: bool = false
var is_held: bool = false

# Button states
enum ButtonState {IDLE, CLICKED, HELD}
var current_state: ButtonState = ButtonState.IDLE

# Simple hold detection
var hold_timer: Timer

# Cooldown to prevent accidental clicks after holding
var click_cooldown_timer: Timer
var is_in_click_cooldown: bool = false

func _ready():
	print("CurrencyGainButton: Initialized")
	
	# Get references to managers
	click_manager = get_node("/root/ClickManager")
	currency_manager = get_node("/root/CurrencyManager")
	
	# Setup hold timer
	hold_timer = Timer.new()
	hold_timer.one_shot = true
	hold_timer.wait_time = 0.1  # 100ms to distinguish click vs hold
	hold_timer.timeout.connect(_on_hold_timer_timeout)
	add_child(hold_timer)
	
	# Setup click cooldown timer
	click_cooldown_timer = Timer.new()
	click_cooldown_timer.one_shot = true
	click_cooldown_timer.wait_time = 0.2  # 200ms cooldown after holding
	click_cooldown_timer.timeout.connect(_on_click_cooldown_timeout)
	add_child(click_cooldown_timer)
	
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
	print("DEBUG: Button pressed signal received")
	# Cancel hold timer and start click action
	hold_timer.stop()
	print("DEBUG: Hold timer stopped")
	
	# Check if we're in click cooldown (prevent accidental clicks after holding)
	if is_in_click_cooldown:
		print("DEBUG: Click blocked - in cooldown after holding")
		return
	
	# Always try to start click action - let ClickManager handle conflicts
	if click_manager:
		print("DEBUG: Starting click action")
		click_manager.start_click_action()
	else:
		print("DEBUG: No click_manager available")

func _on_button_down():
	"""Handle button down (start of hold)"""
	print("DEBUG: Button down signal received")
	is_pressed = true
	# Start hold timer
	hold_timer.start()
	print("DEBUG: Hold timer started")

func _on_hold_timer_timeout():
	"""Handle hold timer timeout - start hold action"""
	print("DEBUG: Hold timer timeout")
	# Only start hold if we're still pressed and no action is in progress
	if is_pressed and click_manager and not click_manager.is_action_in_progress():
		print("DEBUG: Starting hold action")
		click_manager.start_hold_action()
	else:
		print("DEBUG: Cannot start hold action - is_pressed: ", is_pressed, ", click_manager: ", click_manager != null, ", action_in_progress: ", click_manager.is_action_in_progress() if click_manager else "N/A")

func _on_button_up():
	"""Handle button up (end of press)"""
	print("DEBUG: Button up signal received")
	is_pressed = false
	
	# Only stop hold actions when button is released
	# Let click actions complete naturally
	if click_manager and click_manager.is_holding:
		print("DEBUG: Stopping hold action due to button release")
		click_manager.stop_click_action()
	else:
		print("DEBUG: Button released - letting click action complete naturally")

func _on_click_state_changed(is_clicking: bool, is_holding: bool):
	"""Update button state based on click manager state"""
	print("DEBUG: Click state changed - is_clicking: ", is_clicking, ", is_holding: ", is_holding)
	if is_clicking:
		current_state = ButtonState.CLICKED
		is_held = false
	elif is_holding:
		current_state = ButtonState.HELD
		is_held = true
	else:
		current_state = ButtonState.IDLE
		is_held = false
	
	_update_visual_state()

func _on_click_completed(click_type: String, currency_gained: int):
	"""Handle click completion"""
	print("DEBUG: Click completed - ", click_type, " gained ", currency_gained, " currency")
	
	# If this was a hold action that completed, start click cooldown
	if click_type == "hold":
		print("DEBUG: Starting click cooldown after hold completion")
		is_in_click_cooldown = true
		click_cooldown_timer.start()
	
	# For click actions, briefly show "Clicked!" text before returning to idle
	if click_type == "click":
		# Create a timer to reset the button text after a brief delay
		var reset_timer = Timer.new()
		reset_timer.one_shot = true
		reset_timer.wait_time = 0.2  # Show "Clicked!" for 200ms
		reset_timer.timeout.connect(_reset_click_text)
		add_child(reset_timer)
		reset_timer.start()
	
	# Don't reset state here - let click_state_changed handle it
	# This prevents conflicts with continuous holding

func _reset_click_text():
	"""Reset button text after click completion"""
	if current_state == ButtonState.CLICKED:
		current_state = ButtonState.IDLE
		_update_visual_state()

func _on_click_cooldown_timeout():
	"""Handle click cooldown timeout"""
	print("DEBUG: Click cooldown finished")
	is_in_click_cooldown = false

func _update_visual_state():
	"""Update button appearance based on current state"""
	match current_state:
		ButtonState.IDLE:
			# Normal state
			modulate = Color.WHITE
			text = "Gain Currency"
		ButtonState.CLICKED:
			# Clicked state (instant)
			modulate = Color(0.8, 1.0, 0.8, 1.0)  # Light green
			text = "Clicked!"
		ButtonState.HELD:
			# Held state
			modulate = Color(1.0, 0.8, 0.6, 1.0)  # Light orange
			text = "Holding..."

func get_current_state() -> ButtonState:
	"""Get current button state"""
	return current_state

func is_button_active() -> bool:
	"""Check if button is currently active (clicking or holding)"""
	return current_state != ButtonState.IDLE 
