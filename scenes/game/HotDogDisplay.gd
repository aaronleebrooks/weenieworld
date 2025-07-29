extends Control

# Hot dog display for hot dog store idle game
# Uses intentional naming conventions for future maintainability

@onready var hot_dog_label = $HotDogLabel

var hot_dog_manager: Node
var worker_manager: Node


func _ready():
	print("HotDogDisplay: Initialized")

	# Get reference to HotDogManager and WorkerManager
	hot_dog_manager = get_node("/root/HotDogManager")
	worker_manager = get_node_or_null("/root/WorkerManager")

	# Connect to hot dog changes
	if hot_dog_manager:
		hot_dog_manager.hot_dogs_changed.connect(_on_hot_dogs_changed)
		hot_dog_manager.hot_dogs_produced.connect(_on_hot_dogs_produced)
		hot_dog_manager.hot_dogs_sold.connect(_on_hot_dogs_sold)

	# Connect to worker events for rate updates
	if worker_manager:
		worker_manager.production_rates_changed.connect(_on_production_rates_changed)
		worker_manager.worker_hired.connect(_on_worker_event)
		worker_manager.worker_assigned.connect(_on_worker_assignment_event)

	# Connect to viewport size changes for responsive sizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_responsive_layout()

	# Initial display update
	_update_display()


func _on_viewport_size_changed():
	_update_responsive_layout()


func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size

	# Calculate responsive font size
	var font_size_percent = viewport_size.x * 0.025  # 2.5% of viewport width
	var responsive_font_size = max(16, min(font_size_percent, 48))  # 16px to 48px

	if hot_dog_label:
		hot_dog_label.add_theme_font_size_override("font_size", responsive_font_size)

	print("HotDogDisplay: Font size updated to ", responsive_font_size)


func _on_hot_dogs_changed(new_inventory: int, change_amount: int):
	"""Update display when hot dog inventory changes"""
	_update_display()


func _on_hot_dogs_produced(amount: int, source: String):
	"""Handle hot dog production events"""
	print("HotDogDisplay: Hot dogs produced - %d from %s" % [amount, source])
	_update_display()


func _on_hot_dogs_sold(amount: int, value: int):
	"""Handle hot dog sales events"""
	print("HotDogDisplay: Hot dogs sold - %d for %d currency" % [amount, value])
	_update_display()


func _update_display():
	"""Update the display text with current hot dog inventory and rates"""
	if hot_dog_manager and hot_dog_label:
		var formatted_inventory = hot_dog_manager.get_formatted_hot_dogs()
		var production_rate = hot_dog_manager.get_hot_dogs_per_second_total()
		var consumption_rate = hot_dog_manager.get_hot_dog_consumption_per_second()
		var net_rate = hot_dog_manager.get_net_hot_dog_rate()

		# Multi-line display with rate information
		var display_text = "Hot Dogs: %s" % formatted_inventory

		if production_rate > 0:
			display_text += "\n+ %.1f/s" % production_rate
		else:
			display_text += "\n+ 0.0/s"

		if consumption_rate > 0:
			display_text += "\n- %.1f/s" % consumption_rate

		hot_dog_label.text = display_text
	elif hot_dog_label:
		hot_dog_label.text = "Hot Dogs: 0\n+ 0.0/s"


func _on_production_rates_changed():
	"""Update display when production rates change"""
	_update_display()


func _on_worker_event(worker_id: String, cost: int):
	"""Update display when worker is hired"""
	_update_display()


func _on_worker_assignment_event(worker_id: String, assignment: int):
	"""Update display when worker assignment changes"""
	_update_display()
