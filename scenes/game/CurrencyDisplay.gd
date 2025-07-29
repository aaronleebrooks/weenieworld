extends Control

# Currency display for hot dog store idle game
# Uses intentional naming conventions for future maintainability

@onready var currency_label = $CurrencyLabel

var hot_dog_manager: Node
var worker_manager: Node

func _ready():
	print("CurrencyDisplay: Initialized")
	
	# Get reference to HotDogManager and WorkerManager
	hot_dog_manager = get_node("/root/HotDogManager")
	worker_manager = get_node_or_null("/root/WorkerManager")
	
	# Connect to currency changes
	if hot_dog_manager:
		hot_dog_manager.currency_changed.connect(_on_currency_changed)
		hot_dog_manager.currency_earned.connect(_on_currency_earned)
		hot_dog_manager.currency_spent.connect(_on_currency_spent)
	
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
	
	if currency_label:
		currency_label.add_theme_font_size_override("font_size", responsive_font_size)
	
	print("CurrencyDisplay: Font size updated to ", responsive_font_size)

func _on_currency_changed(new_balance: int, change_amount: int):
	"""Update display when currency balance changes"""
	_update_display()

func _on_currency_earned(amount: int, source: String):
	"""Handle currency earned events"""
	print("CurrencyDisplay: Currency earned - %d from %s" % [amount, source])
	_update_display()

func _on_currency_spent(amount: int, reason: String):
	"""Handle currency spent events"""
	print("CurrencyDisplay: Currency spent - %d for %s" % [amount, reason])
	_update_display()

func _update_display():
	"""Update the display text with current currency balance and rate"""
	if hot_dog_manager and currency_label:
		var formatted_currency = hot_dog_manager.get_formatted_currency()
		var currency_rate = hot_dog_manager.get_currency_per_second()
		
		# Multi-line display with rate information
		var display_text = "Currency: %s" % formatted_currency
		if currency_rate > 0:
			display_text += "\n+ %.1f/s" % currency_rate
		else:
			display_text += "\n+ 0.0/s"
		
		currency_label.text = display_text
	elif currency_label:
		currency_label.text = "Currency: 0\n+ 0.0/s"

func _on_production_rates_changed():
	"""Update display when production rates change"""
	_update_display()

func _on_worker_event(worker_id: String, cost: int):
	"""Update display when worker is hired"""
	_update_display()

func _on_worker_assignment_event(worker_id: String, assignment: int):
	"""Update display when worker assignment changes"""
	_update_display()
