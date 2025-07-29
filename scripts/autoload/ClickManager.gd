extends Node

# Click mechanics autoload for handling click interactions and progress bars
# Uses intentional naming conventions for future maintainability

signal click_started(click_type: String)
signal click_completed(click_type: String, hot_dogs_produced: int)
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
var hot_dog_manager: Node


func _ready():
	print("ClickManager: Initialized")

	# Get references to other managers
	hot_dog_manager = get_node("/root/HotDogManager")

	# Create timers for progress tracking
	_setup_timers()

	# Connect to hot dog manager for timing updates
	if hot_dog_manager:
		hot_dog_manager.hot_dogs_changed.connect(_on_hot_dogs_changed)
		# Initialize timer durations immediately
		_update_timer_durations()


func _setup_timers():
	"""Setup timers for click and idle progress tracking"""

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


func _on_hot_dogs_changed(new_inventory: int, change_amount: int):
	"""Update timer durations when hot dog values change"""
	_update_timer_durations()


func _update_timer_durations():
	"""Update timer durations based on current hot dog manager values"""
	if hot_dog_manager:
		idle_progress_timer.wait_time = hot_dog_manager.idle_rate_seconds
		print(
			(
				"ClickManager: Timer durations updated - Click: instant, Idle: %.2fs"
				% [idle_progress_timer.wait_time]
			)
		)


func start_click_action() -> void:
	"""Start a single-click hot dog production action (instant)"""
	if is_clicking:
		return  # Already clicking

	# If we're holding, stop the hold and start click instead
	if is_holding:
		stop_click_action()

	is_clicking = true
	click_progress = 1.0  # Instant completion

	# Produce hot dogs immediately
	if hot_dog_manager:
		var amount = hot_dog_manager.hot_dogs_per_click
		hot_dog_manager.produce_hot_dogs(amount, "click_action")
		emit_signal("click_completed", "click", amount)
	else:
		print("ClickManager: HotDogManager not found!")

	# Reset click state immediately (no progress update needed for instant clicks)
	is_clicking = false


func start_hold_action() -> void:
	"""Start a hold-to-click hot dog production action (timed)"""
	if is_holding:
		return  # Already holding

	# If we're clicking, stop the click and start hold instead
	if is_clicking:
		stop_click_action()

	is_holding = true
	idle_progress = 0.0

	# Start the idle progress timer
	if idle_progress_timer:
		idle_progress_timer.start()

	# Start progress updates
	if progress_update_timer:
		progress_update_timer.start()

	emit_signal("click_started", "hold")
	print("ClickManager: Started hold action")


func stop_click_action() -> void:
	"""Stop any ongoing click action"""
	if is_clicking:
		is_clicking = false
		click_progress = 0.0
		emit_signal("click_state_changed", is_clicking, is_holding)
		print("ClickManager: Stopped click action")


func stop_hold_action() -> void:
	"""Stop any ongoing hold action"""
	if is_holding:
		is_holding = false
		idle_progress = 0.0

		# Stop timers
		if idle_progress_timer:
			idle_progress_timer.stop()
		if progress_update_timer:
			progress_update_timer.stop()

		emit_signal("click_state_changed", is_clicking, is_holding)
		print("ClickManager: Stopped hold action")


func _on_progress_update() -> void:
	"""Update progress bar during hold actions"""
	if is_holding and idle_progress_timer:
		var time_left = idle_progress_timer.time_left
		var total_time = idle_progress_timer.wait_time
		idle_progress = 1.0 - (time_left / total_time)
		emit_signal("click_progress_updated", idle_progress, "hold")


func _on_idle_progress_complete() -> void:
	"""Handle completion of idle progress"""
	print("ClickManager: Idle progress completed")
	idle_progress = 1.0
	emit_signal("click_progress_updated", 1.0, "hold")

	# Produce hot dogs
	if hot_dog_manager:
		var amount = hot_dog_manager.hot_dogs_per_click
		hot_dog_manager.produce_hot_dogs(amount, "hold_action")
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
		print("ClickManager: HotDogManager not found!")


func get_click_progress() -> float:
	"""Get current click progress (0.0 to 1.0)"""
	return click_progress


func get_idle_progress() -> float:
	"""Get current idle progress (0.0 to 1.0)"""
	return idle_progress


func is_action_in_progress() -> bool:
	"""Check if any click action is currently in progress"""
	return is_clicking or is_holding


func get_current_action_type() -> String:
	"""Get the type of action currently in progress"""
	if is_clicking:
		return "click"
	elif is_holding:
		return "hold"
	else:
		return "none"
