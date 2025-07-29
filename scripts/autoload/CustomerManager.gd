extends Node

# Customer sales system autoload for managing customer purchases
# Uses intentional naming conventions for future maintainability

signal customer_purchase(amount: int, value: int)
signal customer_arrived
signal purchase_rate_changed(new_rate: float)

var hot_dog_manager: Node
var purchase_timer: Timer
var purchase_rate_seconds: float = 2.0  # Time between purchases
var purchase_amount: int = 1  # Hot dogs per purchase

# Statistics tracking
var total_customers_served: int = 0
var total_purchases: int = 0


func _ready():
	print("CustomerManager: Initialized")

	# Get reference to HotDogManager
	hot_dog_manager = get_node("/root/HotDogManager")

	# Setup purchase timer
	_setup_purchase_timer()

	# Connect to save system for persistence
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)


func _setup_purchase_timer():
	"""Setup timer for customer purchases"""
	purchase_timer = Timer.new()
	purchase_timer.wait_time = purchase_rate_seconds
	purchase_timer.timeout.connect(_on_purchase_timer_timeout)
	add_child(purchase_timer)
	purchase_timer.start()
	print("CustomerManager: Purchase timer initialized with %.1fs interval" % purchase_rate_seconds)


func _on_save_data_loaded(save_data: Dictionary):
	"""Load customer data from save file"""
	if save_data.has("customers"):
		var customer_data = save_data["customers"]
		purchase_rate_seconds = customer_data.get("purchase_rate", 2.0)
		purchase_amount = customer_data.get("purchase_amount", 1)
		total_customers_served = customer_data.get("total_served", 0)
		total_purchases = customer_data.get("total_purchases", 0)

		# Update timer with loaded rate
		if purchase_timer:
			purchase_timer.wait_time = purchase_rate_seconds
		print("CustomerManager: Loaded customer data from save")


func get_save_data() -> Dictionary:
	"""Get customer data for saving"""
	return {
		"customers":
		{
			"purchase_rate": purchase_rate_seconds,
			"purchase_amount": purchase_amount,
			"total_served": total_customers_served,
			"total_purchases": total_purchases
		}
	}


func _on_purchase_timer_timeout():
	"""Handle customer purchase attempt"""
	if not hot_dog_manager:
		print("CustomerManager: HotDogManager not found!")
		return

	# Check if we have enough hot dogs to sell
	if hot_dog_manager.hot_dogs_inventory >= purchase_amount:
		if hot_dog_manager.sell_hot_dogs(purchase_amount):
			total_customers_served += 1
			total_purchases += 1
			var earned_value = purchase_amount * hot_dog_manager.sale_value
			emit_signal("customer_purchase", purchase_amount, earned_value)
			emit_signal("customer_arrived")
			print(
				(
					"CustomerManager: Customer purchased %d hot dogs for %d currency"
					% [purchase_amount, earned_value]
				)
			)
		else:
			print("CustomerManager: Failed to sell hot dogs to customer")
	else:
		print(
			(
				"CustomerManager: Not enough hot dogs for customer (have %d, need %d)"
				% [hot_dog_manager.hot_dogs_inventory, purchase_amount]
			)
		)


func set_purchase_rate(new_rate: float):
	"""Update customer purchase rate"""
	if new_rate > 0:
		purchase_rate_seconds = new_rate
		if purchase_timer:
			purchase_timer.wait_time = purchase_rate_seconds
		emit_signal("purchase_rate_changed", new_rate)
		print("CustomerManager: Purchase rate updated to %.1fs" % new_rate)


func set_purchase_amount(new_amount: int):
	"""Update amount of hot dogs purchased per customer"""
	if new_amount > 0:
		purchase_amount = new_amount
		print("CustomerManager: Purchase amount updated to %d hot dogs" % new_amount)


func get_purchase_rate() -> float:
	"""Get current purchase rate in seconds"""
	return purchase_rate_seconds


func get_purchase_amount() -> int:
	"""Get current purchase amount"""
	return purchase_amount


func get_customers_per_minute() -> float:
	"""Get customers served per minute"""
	if purchase_rate_seconds > 0:
		return 60.0 / purchase_rate_seconds
	return 0.0


func reset_customers() -> void:
	"""Reset customer system to starting values (for new game)"""
	purchase_rate_seconds = 2.0
	purchase_amount = 1
	total_customers_served = 0
	total_purchases = 0

	if purchase_timer:
		purchase_timer.wait_time = purchase_rate_seconds

	print("CustomerManager: Reset to starting values")


func pause_customers():
	"""Pause customer purchases"""
	if purchase_timer:
		purchase_timer.paused = true
		print("CustomerManager: Customer purchases paused")


func resume_customers():
	"""Resume customer purchases"""
	if purchase_timer:
		purchase_timer.paused = false
		print("CustomerManager: Customer purchases resumed")
