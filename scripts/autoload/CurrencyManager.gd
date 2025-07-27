extends Node

# Currency system autoload for global currency management
# Uses intentional naming conventions for future maintainability

signal currency_changed(new_balance: int, change_amount: int)
signal currency_gained(amount: int, source: String)
signal currency_spent(amount: int, reason: String)

# Core currency values
var currency_balance: int = 0:
	set(value):
		var old_balance = currency_balance
		currency_balance = value
		if old_balance != currency_balance:
			emit_signal("currency_changed", currency_balance, currency_balance - old_balance)

var currency_per_click: int = 1:
	set(value):
		currency_per_click = max(1, value)  # Minimum 1 currency per click

# Timing values (in seconds)
var click_rate_seconds: float = 0.1:
	set(value):
		click_rate_seconds = max(0.05, value)  # Minimum 0.05 seconds

var idle_rate_seconds: float = 0.3:
	set(value):
		idle_rate_seconds = max(0.1, value)  # Minimum 0.1 seconds

# Currency formatting
var currency_formatter: CurrencyFormatter

func _ready():
	print("CurrencyManager: Initialized")
	currency_formatter = CurrencyFormatter.new()
	
	# Connect to save system for persistence
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.save_data_loaded.connect(_on_save_data_loaded)

func _on_save_data_loaded(save_data: Dictionary):
	"""Load currency data from save file"""
	if save_data.has("currency"):
		var currency_data = save_data["currency"]
		currency_balance = currency_data.get("balance", 0)
		currency_per_click = currency_data.get("per_click", 1)
		click_rate_seconds = currency_data.get("click_rate", 0.1)
		idle_rate_seconds = currency_data.get("idle_rate", 0.3)
		print("CurrencyManager: Loaded currency data from save")

func get_save_data() -> Dictionary:
	"""Get currency data for saving"""
	return {
		"currency": {
			"balance": currency_balance,
			"per_click": currency_per_click,
			"click_rate": click_rate_seconds,
			"idle_rate": idle_rate_seconds
		}
	}

func gain_currency(amount: int, source: String = "unknown") -> void:
	"""Add currency to balance with source tracking"""
	if amount > 0:
		currency_balance += amount
		emit_signal("currency_gained", amount, source)
		print("CurrencyManager: Gained %d currency from %s (new balance: %d)" % [amount, source, currency_balance])

func spend_currency(amount: int, reason: String = "unknown") -> bool:
	"""Spend currency if sufficient balance exists"""
	if amount <= 0:
		return false
	
	if currency_balance >= amount:
		currency_balance -= amount
		emit_signal("currency_spent", amount, reason)
		print("CurrencyManager: Spent %d currency for %s (new balance: %d)" % [amount, reason, currency_balance])
		return true
	else:
		print("CurrencyManager: Insufficient currency for %s (need %d, have %d)" % [reason, amount, currency_balance])
		return false

func can_afford(amount: int) -> bool:
	"""Check if player can afford the specified amount"""
	return currency_balance >= amount

func get_formatted_currency() -> String:
	"""Get formatted currency string (e.g., "1,234" or "1.2K")"""
	return currency_formatter.format(currency_balance)

func reset_currency() -> void:
	"""Reset currency to starting values (for new game)"""
	currency_balance = 0
	currency_per_click = 1
	click_rate_seconds = 0.1
	idle_rate_seconds = 0.3
	print("CurrencyManager: Reset to starting values")

# Currency formatting helper class
class CurrencyFormatter:
	func format(amount: int) -> String:
		"""Format currency amount with appropriate suffixes"""
		if amount < 1000:
			return str(amount)
		elif amount < 1000000:
			return "%.1fK" % (amount / 1000.0)
		elif amount < 1000000000:
			return "%.1fM" % (amount / 1000000.0)
		else:
			return "%.1fB" % (amount / 1000000000.0) 