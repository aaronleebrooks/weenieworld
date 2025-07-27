extends Control
class_name ResponsiveModal

# Responsive modal that adjusts size based on viewport
@export var min_width: float = 400.0
@export var min_height: float = 300.0
@export var max_width_percent: float = 0.8  # 80% of viewport width
@export var max_height_percent: float = 0.8  # 80% of viewport height

func _ready():
	# Connect to viewport size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_size()

func _on_viewport_size_changed():
	_update_size()

func _update_size():
	var viewport_size = get_viewport().get_visible_rect().size
	var target_width = min(viewport_size.x * max_width_percent, viewport_size.x - 100)
	var target_height = min(viewport_size.y * max_height_percent, viewport_size.y - 100)
	
	# Ensure minimum size
	target_width = max(target_width, min_width)
	target_height = max(target_height, min_height)
	
	# Update the modal panel size (check both MenuPanel and DialogPanel)
	var panel = get_node_or_null("MenuPanel")
	if not panel:
		panel = get_node_or_null("DialogPanel")
	
	if panel:
		panel.offset_left = -target_width / 2
		panel.offset_top = -target_height / 2
		panel.offset_right = target_width / 2
		panel.offset_bottom = target_height / 2 