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
	
	# Click progress timer (single click)
	click_progress_timer = Timer.new()
	click_progress_timer.one_shot = true
	click_progress_timer.timeout.connect(_on_click_progress_complete)
	add_child(click_progress_timer)
	
	# Idle progress timer (hold to click)
	idle_progress_timer = Timer.new()
	idle_progress_timer.one_shot = true
	idle_progress_timer.timeout.connect(_on_idle_progress_complete)
	add_child(idle_progress_timer)
	
	print("ClickManager: Timers initialized")

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Update timer durations when currency values change"""
	_update_timer_durations()

func _update_timer_durations():
	"""Update timer durations based on current currency manager values"""
	if currency_manager:
		click_progress_timer.wait_time = currency_manager.click_rate_seconds
		idle_progress_timer.wait_time = currency_manager.idle_rate_seconds
		print("ClickManager: Timer durations updated - Click: %.2fs, Idle: %.2fs" % [click_progress_timer.wait_time, idle_progress_timer.wait_time])

func start_click_action() -> void:
	"""Start a single-click currency gain action"""
	print("DEBUG: ClickManager.start_click_action() called")
	if is_clicking:
		print("DEBUG: Cannot start click action - already clicking")
		return  # Already clicking
	
	# If we're holding, stop the hold and start click instead
	if is_holding:
		print("DEBUG: Stopping hold action to start click")
		stop_click_action()
	
	print("DEBUG: ClickManager: Starting click action")
	is_clicking = true
	click_progress = 0.0
	
	# Start the click progress timer
	click_progress_timer.start()
	emit_signal("click_started", "click")
	
	# Start progress updates
	_start_progress_updates("click")

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
		click_progress_timer.stop()
		click_progress = 0.0
		emit_signal("click_progress_updated", 0.0, "click")
	
	if is_holding:
		print("ClickManager: Stopping hold action")
		is_holding = false
		idle_progress_timer.stop()
		idle_progress = 0.0
		emit_signal("click_progress_updated", 0.0, "hold")

func _start_progress_updates(click_type: String) -> void:
	"""Start updating progress for the specified click type"""
	# Create a timer for smooth progress updates
	var progress_timer = Timer.new()
	progress_timer.wait_time = 0.016  # ~60 FPS updates
	progress_timer.timeout.connect(_update_progress.bind(click_type))
	add_child(progress_timer)
	progress_timer.start()

func _update_progress(click_type: String) -> void:
	"""Update progress for the specified click type"""
	var target_timer = click_progress_timer if click_type == "click" else idle_progress_timer
	var current_progress = click_progress if click_type == "click" else idle_progress
	
	if target_timer and target_timer.time_left > 0:
		var elapsed = target_timer.wait_time - target_timer.time_left
		var new_progress = elapsed / target_timer.wait_time
		
		if click_type == "click":
			click_progress = new_progress
		else:
			idle_progress = new_progress
		
		emit_signal("click_progress_updated", new_progress, click_type)

func _on_click_progress_complete() -> void:
	"""Handle completion of click progress"""
	print("ClickManager: Click progress completed")
	is_clicking = false
	click_progress = 1.0
	emit_signal("click_progress_updated", 1.0, "click")
	
	# Award currency
	if currency_manager:
		var amount = currency_manager.currency_per_click
		currency_manager.gain_currency(amount, "click_action")
		emit_signal("click_completed", "click", amount)
	else:
		print("ClickManager: CurrencyManager not found!")

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
			# If not holding anymore, reset state
			is_holding = false
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