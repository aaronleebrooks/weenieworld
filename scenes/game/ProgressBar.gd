extends Control

# Progress bar for hot dog production hold actions
# Uses intentional naming conventions for future maintainability

@onready var progress_fill = $ProgressFill

var click_manager: Node
var current_progress: float = 0.0

func _ready():
	print("ProgressBar: Initialized")
	
	# Get reference to ClickManager
	click_manager = get_node("/root/ClickManager")
	
	# Connect to click manager events
	if click_manager:
		click_manager.click_progress_updated.connect(_on_click_progress_updated)
		click_manager.click_completed.connect(_on_click_completed)
		click_manager.click_state_changed.connect(_on_click_state_changed)
	
	# Connect to viewport size changes for responsive sizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_responsive_layout()
	
	# Start hidden
	visible = false

func _on_viewport_size_changed():
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive size
	var width_percent = viewport_size.x * 0.3  # 30% of viewport width
	var height_percent = viewport_size.y * 0.02  # 2% of viewport height
	
	var responsive_width = max(200, min(width_percent, 600))  # 200px to 600px
	var responsive_height = max(8, min(height_percent, 20))   # 8px to 20px
	
	custom_minimum_size = Vector2(responsive_width, responsive_height)
	
	print("ProgressBar: Size updated to ", custom_minimum_size)

func _on_click_progress_updated(progress: float, click_type: String):
	"""Update progress bar based on click progress"""
	if click_type == "hold":
		current_progress = progress
		_update_progress_display()
		visible = true
		print("ProgressBar: Progress updated to %.1f%%" % (progress * 100))

func _on_click_completed(click_type: String, hot_dogs_produced: int):
	"""Handle click completion"""
	print("ProgressBar: Click completed - ", click_type, " produced ", hot_dogs_produced, " hot dogs")
	
	# Hide progress bar when click is complete
	visible = false
	current_progress = 0.0
	_update_progress_display()

func _on_click_state_changed(is_clicking: bool, is_holding: bool):
	"""Handle click state changes"""
	if is_holding:
		# Show progress bar for hold actions
		visible = true
		current_progress = 0.0
		_update_progress_display()
		print("ProgressBar: Hold started, showing progress bar")
	elif not is_clicking and not is_holding:
		# Hide progress bar when no action is in progress
		visible = false
		current_progress = 0.0
		_update_progress_display()
		print("ProgressBar: No action in progress, hiding progress bar")

func _update_progress_display():
	"""Update the visual progress bar"""
	if progress_fill:
		# Update progress fill width
		progress_fill.anchor_right = current_progress
		
		# Set color based on progress type
		progress_fill.color = Color(0.8, 0.6, 0.2, 1.0)  # Orange for hot dog production 