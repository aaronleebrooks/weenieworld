extends Control

@onready var progress_fill = $ProgressFill

var current_progress: float = 0.0
var is_visible: bool = false

func _ready():
	print("ProgressBar: Initialized")
	
	# Connect to click manager signals
	var click_manager = get_node("/root/ClickManager")
	if click_manager:
		click_manager.click_progress_updated.connect(_on_progress_updated)
		click_manager.click_state_changed.connect(_on_click_state_changed)
		click_manager.click_completed.connect(_on_click_completed)
	
	# Start hidden
	visible = false
	
	# Connect to viewport size changes for responsive sizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_responsive_layout()

func _on_viewport_size_changed():
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive size (like CSS vw/vh units)
	var width_percent = viewport_size.x * 0.4  # 40% of viewport width
	var height_percent = viewport_size.y * 0.03  # 3% of viewport height
	
	var responsive_width = max(200, min(width_percent, 400))  # 200px to 400px
	var responsive_height = max(15, min(height_percent, 30))  # 15px to 30px
	
	offset_left = -responsive_width / 2
	offset_right = responsive_width / 2
	offset_top = -responsive_height / 2
	offset_bottom = responsive_height / 2
	
	print("ProgressBar: Size updated to ", Vector2(responsive_width, responsive_height))

func _on_progress_updated(progress: float, click_type: String):
	"""Update progress bar based on click progress"""
	current_progress = progress
	_update_progress_display(click_type)

func _on_click_state_changed(is_clicking: bool, is_holding: bool):
	"""Show/hide progress bar based on click state"""
	is_visible = is_clicking or is_holding
	visible = is_visible
	
	if is_visible:
		print("ProgressBar: Showing progress bar")
	else:
		print("ProgressBar: Hiding progress bar")
		current_progress = 0.0
		_update_progress_display("none")

func _on_click_completed(click_type: String, currency_gained: int):
	"""Handle click completion"""
	print("ProgressBar: Click completed - ", click_type, " gained ", currency_gained, " currency")
	# For hold actions, keep the progress bar visible and restart
	if click_type == "hold":
		# Reset progress and keep visible for continuous holding
		current_progress = 0.0
		_update_progress_display("hold")
		print("ProgressBar: Restarting hold progress bar")

func _update_progress_display(click_type: String):
	"""Update the visual progress bar"""
	if not progress_fill:
		return
	
	# Update progress fill width
	progress_fill.anchor_right = current_progress
	
	# Update color based on click type
	match click_type:
		"click":
			progress_fill.color = Color(0.2, 0.8, 0.2, 1.0)  # Green for click
		"hold":
			progress_fill.color = Color(0.8, 0.6, 0.2, 1.0)  # Orange for hold
		_:
			progress_fill.color = Color(0.2, 0.2, 0.2, 1.0)  # Gray for none
	
	print("ProgressBar: Progress updated to %.2f%% (%s)" % [current_progress * 100, click_type])

func set_progress(progress: float):
	"""Manually set progress (0.0 to 1.0)"""
	current_progress = clamp(progress, 0.0, 1.0)
	_update_progress_display("manual")

func get_progress() -> float:
	"""Get current progress value"""
	return current_progress 