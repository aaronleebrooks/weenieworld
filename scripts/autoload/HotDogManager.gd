extends Node

# Hot dog production system autoload for global hot dog management
# Uses intentional naming conventions for future maintainability

const DEBUG_MODE: bool = false

signal hot_dogs_changed(new_inventory: int, change_amount: int)
signal hot_dogs_produced(amount: int, source: String)
signal hot_dogs_sold(amount: int, value: int)
signal currency_changed(new_balance: int, change_amount: int)
signal currency_earned(amount: int, source: String)
signal currency_spent(amount: int, reason: String)

# Core hot dog values
var hot_dogs_inventory: int = 0:
	set(value):
		var old_inventory = hot_dogs_inventory
		hot_dogs_inventory = value
		if old_inventory != hot_dogs_inventory:
			emit_signal("hot_dogs_changed", hot_dogs_inventory, hot_dogs_inventory - old_inventory)

var hot_dogs_per_click: int = 1:
	set(value):
		hot_dogs_per_click = max(1, value)  # Minimum 1 hot dog per click

# Timing values (in seconds)
var production_rate_seconds: float = 0.3:
	set(value):
		production_rate_seconds = max(0.05, value)  # Minimum 0.05 seconds

var idle_rate_seconds: float = 0.3:
	set(value):
		idle_rate_seconds = max(0.1, value)  # Minimum 0.1 seconds

# Currency from sales
var currency_balance: int = 0:
	set(value):
		var old_balance = currency_balance
		currency_balance = value
		if old_balance != currency_balance:
			emit_signal("currency_changed", currency_balance, currency_balance - old_balance)

var sale_value: int = 1  # Currency per hot dog sold

# Statistics tracking
var total_hot_dogs_produced: int = 0
var total_hot_dogs_sold: int = 0
var total_currency_earned: int = 0

# Currency formatting
var currency_formatter: CurrencyFormatter


func _ready() -> void:
	if DEBUG_MODE:
		print("HotDogManager: Initialized")
	currency_formatter = CurrencyFormatter.new()

	# Connect to save system for persistence
	var save_system: Node = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)


func _on_save_data_loaded(save_data: Dictionary) -> void:
	"""Load hot dog data from save file"""
	if save_data.has("hot_dogs"):
		var hot_dogs_data: Dictionary = save_data["hot_dogs"]
		hot_dogs_inventory = hot_dogs_data.get("inventory", 0)
		hot_dogs_per_click = hot_dogs_data.get("per_click", 1)
		production_rate_seconds = hot_dogs_data.get("production_rate", 0.3)
		idle_rate_seconds = hot_dogs_data.get("idle_rate", 0.3)
		sale_value = hot_dogs_data.get("sale_value", 1)
		total_hot_dogs_produced = hot_dogs_data.get("total_produced", 0)
		total_hot_dogs_sold = hot_dogs_data.get("total_sold", 0)
		total_currency_earned = hot_dogs_data.get("total_currency_earned", 0)
		if DEBUG_MODE:
			print("HotDogManager: Loaded hot dog data from save")

	# Load currency data
	if save_data.has("currency"):
		var currency_data: Dictionary = save_data["currency"]
		currency_balance = currency_data.get("balance", 0)
		if DEBUG_MODE:
			print("HotDogManager: Loaded currency data from save")


func get_save_data() -> Dictionary:
	"""Get hot dog data for saving"""
	return {
		"hot_dogs":
		{
			"inventory": hot_dogs_inventory,
			"per_click": hot_dogs_per_click,
			"production_rate": production_rate_seconds,
			"idle_rate": idle_rate_seconds,
			"sale_value": sale_value,
			"total_produced": total_hot_dogs_produced,
			"total_sold": total_hot_dogs_sold,
			"total_currency_earned": total_currency_earned
		},
		"currency": {"balance": currency_balance}
	}


func produce_hot_dogs(amount: int, source: String = "unknown") -> void:
	"""Produce hot dogs and add to inventory"""
	if amount > 0:
		hot_dogs_inventory += amount
		total_hot_dogs_produced += amount
		emit_signal("hot_dogs_produced", amount, source)


func sell_hot_dogs(amount: int) -> bool:
	"""Sell hot dogs from inventory and earn currency"""
	if amount <= 0 or hot_dogs_inventory < amount:
		return false

	hot_dogs_inventory -= amount
	var earned_currency: int = amount * sale_value
	currency_balance += earned_currency
	total_hot_dogs_sold += amount
	total_currency_earned += earned_currency

	emit_signal("hot_dogs_sold", amount, earned_currency)
	emit_signal("currency_earned", earned_currency, "hot_dog_sale")
	return true


func spend_currency(amount: int, reason: String = "unknown") -> bool:
	"""Spend currency if sufficient balance exists"""
	if amount <= 0:
		return false

	if currency_balance >= amount:
		currency_balance -= amount
		emit_signal("currency_spent", amount, reason)
		if DEBUG_MODE:
			print(
				(
					"HotDogManager: Spent %d currency for %s (new balance: %d)"
					% [amount, reason, currency_balance]
				)
			)
		return true

	if DEBUG_MODE:
		print(
			(
				"HotDogManager: Insufficient currency for %s (need %d, have %d)"
				% [reason, amount, currency_balance]
			)
		)
	return false


func can_afford(amount: int) -> bool:
	"""Check if player can afford the specified amount"""
	return currency_balance >= amount


func get_formatted_currency() -> String:
	"""Get formatted currency string (e.g., "1, 234" or "1.2K")"""
	return currency_formatter.format(currency_balance)


func get_formatted_hot_dogs() -> String:
	"""Get formatted hot dog inventory string"""
	return currency_formatter.format(hot_dogs_inventory)


func get_currency_per_second() -> float:
	"""Calculate currency earned per second from customer purchases"""
	var customer_manager = get_node_or_null("/root/CustomerManager")
	if not customer_manager:
		return 0.0

	# Currency per second = (hot dogs per purchase * sale value) / purchase interval
	var purchases_per_second = 1.0 / customer_manager.get_purchase_rate()
	var purchase_amount = customer_manager.get_purchase_amount()
	return purchases_per_second * purchase_amount * sale_value


func get_hot_dogs_per_second_manual() -> float:
	"""Calculate hot dog production per second from manual clicking / holding"""
	# This is an estimate based on typical clicking patterns
	# For now, we'll estimate 1 click every 2 seconds during active play
	return hot_dogs_per_click * 0.5


func get_hot_dogs_per_second_workers() -> float:
	"""Calculate hot dog production per second from workers"""
	var worker_manager = get_node_or_null("/root/WorkerManager")
	if not worker_manager:
		return 0.0

	return worker_manager.get_kitchen_production_rate()


func get_hot_dogs_per_second_total() -> float:
	"""Calculate total hot dog production per second (manual + workers)"""
	return get_hot_dogs_per_second_manual() + get_hot_dogs_per_second_workers()


func get_hot_dog_consumption_per_second() -> float:
	"""Calculate hot dog consumption per second from workers"""
	var worker_manager = get_node_or_null("/root/WorkerManager")
	if not worker_manager:
		return 0.0

	return worker_manager.get_total_consumption_rate()


func get_net_hot_dog_rate() -> float:
	"""Calculate net hot dog rate (production - consumption)"""
	return get_hot_dogs_per_second_total() - get_hot_dog_consumption_per_second()


func reset_hot_dogs() -> void:
	"""Reset hot dog system to starting values (for new game)"""
	hot_dogs_inventory = 0
	hot_dogs_per_click = 1
	production_rate_seconds = 0.3
	idle_rate_seconds = 0.3
	sale_value = 1
	total_hot_dogs_produced = 0
	total_hot_dogs_sold = 0
	total_currency_earned = 0
	currency_balance = 0
	if DEBUG_MODE:
		print("HotDogManager: Reset to starting values")

	# Also reset upgrades
	var upgrade_manager: Node = get_node_or_null("/root/UpgradeManager")
	if upgrade_manager:
		upgrade_manager.reset_upgrades()


# Currency formatting helper class
class CurrencyFormatter:
	func format(amount: int) -> String:
		"""Format amount with appropriate suffixes"""
		if amount < 1000:
			return str(amount)
		if amount < 1000000:
			return "%.1fK" % (amount / 1000.0)
		if amount < 1000000000:
			return "%.1fM" % (amount / 1000000.0)
		return "%.1fB" % (amount / 1000000000.0)
