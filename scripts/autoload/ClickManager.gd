extends Node

# Click mechanics autoload for handling click interactions and progress bars
# Uses intentional naming conventions for future maintainability

signal click_started(click_type: String)
signal click_completed(click_type: String, currency_gained: int)
signal click_progress_updated(progress: float, click_type: String)
signal click_state_changed(is_clicking: bool, is_holding: bool)

# Click state tracking
var is_clicking: bool = false:
	set(value):
		is_clicking = value
		emit_signal("click_state_changed", is_clicking, is_holding)

var is_holding: bool = false:
	set(value):
		is_holding = value
		emit_signal("click_state_changed", is_clicking, is_holding)

# Progress tracking
var click_progress: float = 0.0
var idle_progress: float = 0.0

# Timers for progress tracking
var click_progress_timer: Timer
var idle_progress_timer: Timer
var progress_update_timer: Timer

# References to managers
var currency_manager: Node

func _ready():
	print("ClickManager: Initialized")
	
	# Get references to other managers
	currency_manager = get_node("/root/CurrencyManager")
	
	# Create timers for progress tracking
	_setup_timers()
	
	# Connect to currency manager for timing updates
	if currency_manager:
		currency_manager.currency_changed.connect(_on_currency_changed)
		# Initialize timer durations immediately
		_update_timer_durations()

func _setup_timers():
	"""Setup timers for click and idle progress tracking"""
	
	# Click progress timer (no longer needed for instant clicks)
	# click_progress_timer = Timer.new()
	# click_progress_timer.one_shot = true
	# click_progress_timer.timeout.connect(_on_click_progress_complete)
	# add_child(click_progress_timer)
	
	# Idle progress timer (hold to click)
	idle_progress_timer = Timer.new()
	idle_progress_timer.one_shot = true
	idle_progress_timer.timeout.connect(_on_idle_progress_complete)
	add_child(idle_progress_timer)
	
	# Progress update timer for smooth progress bar updates
	progress_update_timer = Timer.new()
	progress_update_timer.wait_time = 0.016  # ~60 FPS updates
	progress_update_timer.timeout.connect(_on_progress_update)
	add_child(progress_update_timer)
	
	print("ClickManager: Timers initialized")

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Update timer durations when currency values change"""
	_update_timer_durations()

func _update_timer_durations():
	"""Update timer durations based on current currency manager values"""
	if currency_manager:
		# Click timer no longer needed for instant clicks
		# click_progress_timer.wait_time = currency_manager.click_rate_seconds
		idle_progress_timer.wait_time = currency_manager.idle_rate_seconds
		print("ClickManager: Timer durations updated - Click: instant, Idle: %.2fs" % [idle_progress_timer.wait_time])

func start_click_action() -> void:
	"""Start a single-click currency gain action (instant)"""
	print("DEBUG: ClickManager.start_click_action() called")
	if is_clicking:
		print("DEBUG: Cannot start click action - already clicking")
		return  # Already clicking
	
	# If we're holding, stop the hold and start click instead
	if is_holding:
		print("DEBUG: Stopping hold action to start click")
		stop_click_action()
	
	print("DEBUG: ClickManager: Starting instant click action")
	is_clicking = true
	click_progress = 1.0  # Instant completion
	
	# Award currency immediately
	if currency_manager:
		var amount = currency_manager.currency_per_click
		currency_manager.gain_currency(amount, "click_action")
		emit_signal("click_completed", "click", amount)
		print("ClickManager: Awarded %d currency for instant click action" % amount)
	else:
		print("ClickManager: CurrencyManager not found!")
	
	# Reset click state immediately (no progress update needed for instant clicks)
	is_clicking = false

func start_hold_action() -> void:
	"""Start a hold-to-click currency gain action"""
	if is_clicking or is_holding:
		return  # Already in progress
	
	print("ClickManager: Starting hold action")
	is_holding = true
	idle_progress = 0.0
	
	# Start the idle progress timer
	idle_progress_timer.start()
	emit_signal("click_started", "hold")
	
	# Start progress updates
	_start_progress_updates("hold")

func stop_click_action() -> void:
	"""Stop any ongoing click action"""
	if is_clicking:
		print("ClickManager: Stopping click action")
		is_clicking = false
		click_progress = 0.0
		# No progress update needed for instant clicks
	
	if is_holding:
		print("ClickManager: Stopping hold action")
		is_holding = false
		idle_progress_timer.stop()
		idle_progress = 0.0
		emit_signal("click_progress_updated", 0.0, "hold")
	
	# Stop progress update timer if no actions are in progress
	if not is_clicking and not is_holding:
		progress_update_timer.stop()

func _start_progress_updates(click_type: String) -> void:
	"""Start updating progress for the specified click type"""
	# Start the progress update timer if not already running
	if not progress_update_timer.is_stopped():
		progress_update_timer.stop()
	progress_update_timer.start()

func _on_progress_update() -> void:
	"""Update progress for the current action"""
	if is_clicking:
		_update_click_progress()
	elif is_holding:
		_update_hold_progress()

func _update_click_progress() -> void:
	"""Update progress for click action (instant)"""
	# Clicks are now instant, so no progress updates needed
	pass

func _update_hold_progress() -> void:
	"""Update progress for hold action"""
	if idle_progress_timer and idle_progress_timer.time_left > 0:
		var elapsed = idle_progress_timer.wait_time - idle_progress_timer.time_left
		var new_progress = elapsed / idle_progress_timer.wait_time
		idle_progress = new_progress
		emit_signal("click_progress_updated", new_progress, "hold")
		# Debug: Log progress every 25%
		if int(new_progress * 100) % 25 == 0 and new_progress > 0:
			print("DEBUG: Hold progress: %.0f%%" % (new_progress * 100))

# Click actions are now instant, so this function is no longer needed
# func _on_click_progress_complete() -> void:
# 	"""Handle completion of click progress"""
# 	# Removed - clicks are now instant

func _on_idle_progress_complete() -> void:
	"""Handle completion of idle progress"""
	print("ClickManager: Idle progress completed")
	idle_progress = 1.0
	emit_signal("click_progress_updated", 1.0, "hold")
	
	# Award currency
	if currency_manager:
		var amount = currency_manager.currency_per_click
		currency_manager.gain_currency(amount, "hold_action")
		emit_signal("click_completed", "hold", amount)
		
		# For continuous holding, restart the timer if still holding
		if is_holding:
			idle_progress = 0.0
			idle_progress_timer.start()
			print("ClickManager: Restarting hold timer for continuous holding")
		else:
			# If not holding anymore, reset state and stop progress updates
			is_holding = false
			progress_update_timer.stop()
			emit_signal("click_state_changed", is_clicking, is_holding)
	else:
		print("ClickManager: CurrencyManager not found!")

func get_click_progress() -> float:
	"""Get current click progress (0.0 to 1.0)"""
	return click_progress

func get_idle_progress() -> float:
	"""Get current idle progress (0.0 to 1.0)"""
	return idle_progress

func is_action_in_progress() -> bool:
	"""Check if any click action is currently in progress"""
	var in_progress = is_clicking or is_holding
	print("DEBUG: ClickManager.is_action_in_progress() = ", in_progress, " (is_clicking: ", is_clicking, ", is_holding: ", is_holding, ")")
	return in_progress

func get_current_action_type() -> String:
	"""Get the type of action currently in progress"""
	if is_clicking:
		return "click"
	elif is_holding:
		return "hold"
	else:
		return "none" 