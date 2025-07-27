extends Control

# Hot dog display for hot dog store idle game
# Uses intentional naming conventions for future maintainability

@onready var hot_dog_label = $HotDogLabel

var hot_dog_manager: Node

func _ready():
	print("HotDogDisplay: Initialized")
	
	# Get reference to HotDogManager
	hot_dog_manager = get_node("/root/HotDogManager")
	
	# Connect to hot dog changes
	if hot_dog_manager:
		hot_dog_manager.hot_dogs_changed.connect(_on_hot_dogs_changed)
		hot_dog_manager.hot_dogs_produced.connect(_on_hot_dogs_produced)
		hot_dog_manager.hot_dogs_sold.connect(_on_hot_dogs_sold)
	
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
	"""Update the display text with current hot dog inventory"""
	if hot_dog_manager and hot_dog_label:
		var formatted_inventory = hot_dog_manager.get_formatted_hot_dogs()
		hot_dog_label.text = "Hot Dogs: %s" % formatted_inventory
	elif hot_dog_label:
		hot_dog_label.text = "Hot Dogs: 0" 