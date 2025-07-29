extends GdUnitTestSuite

# Test suite for HotDogManager autoload
# Tests hot dog production, inventory management, and sales functionality

var hot_dog_manager: Node


func before():
	"""Setup before each test"""
	hot_dog_manager = get_node_or_null("/root/HotDogManager")
	if not hot_dog_manager:
		# If autoload not available, create a mock instance for testing
		hot_dog_manager = preload("res://scripts/autoload/HotDogManager.gd").new()
		add_child(hot_dog_manager)

	# Reset state for clean tests
	hot_dog_manager.hot_dogs_inventory = 0
	hot_dog_manager.currency_balance = 0


func test_produce_hot_dogs():
	"""Test hot dog production increases inventory"""
	var initial_inventory: int = hot_dog_manager.hot_dogs_inventory
	var production_amount: int = 5

	hot_dog_manager.produce_hot_dogs(production_amount, "test")

	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(initial_inventory + production_amount)


func test_produce_hot_dogs_emits_signal():
	"""Test that producing hot dogs emits the correct signal"""
	var signal_emitted = false
	hot_dog_manager.hot_dogs_produced.connect(func(amount, reason): signal_emitted = true)
	
	hot_dog_manager.produce_hot_dogs(3, "unit_test")
	
	assert_bool(signal_emitted).is_true()


func test_sell_hot_dogs_success():
	"""Test successful hot dog sale"""
	# Setup: have some hot dogs in inventory
	hot_dog_manager.hot_dogs_inventory = 10
	hot_dog_manager.sale_value = 2
	var initial_currency: int = hot_dog_manager.currency_balance

	var result: bool = hot_dog_manager.sell_hot_dogs(3)

	assert_bool(result).is_true()
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(7)
	assert_int(hot_dog_manager.currency_balance).is_equal(initial_currency + 6)


func test_sell_hot_dogs_insufficient_inventory():
	"""Test selling more hot dogs than available"""
	hot_dog_manager.hot_dogs_inventory = 2
	var initial_currency: int = hot_dog_manager.currency_balance

	var result: bool = hot_dog_manager.sell_hot_dogs(5)

	assert_bool(result).is_false()
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(2)  # Unchanged
	assert_int(hot_dog_manager.currency_balance).is_equal(initial_currency)  # Unchanged


func test_sell_hot_dogs_emits_signal():
	"""Test that selling hot dogs emits the correct signal"""
	hot_dog_manager.hot_dogs_inventory = 10
	hot_dog_manager.sale_value = 3
	
	var signal_emitted = false
	hot_dog_manager.hot_dogs_sold.connect(func(amount, value): signal_emitted = true)

	hot_dog_manager.sell_hot_dogs(2)

	assert_bool(signal_emitted).is_true()


func test_zero_production():
	"""Test that zero or negative production amounts are handled correctly"""
	var initial_inventory: int = hot_dog_manager.hot_dogs_inventory

	hot_dog_manager.produce_hot_dogs(0, "test")
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(initial_inventory)

	hot_dog_manager.produce_hot_dogs(-5, "test")
	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(initial_inventory)


func test_zero_sale():
	"""Test that zero or negative sale amounts are handled correctly"""
	hot_dog_manager.hot_dogs_inventory = 10
	var initial_inventory: int = hot_dog_manager.hot_dogs_inventory
	var initial_currency: int = hot_dog_manager.currency_balance

	var result1: bool = hot_dog_manager.sell_hot_dogs(0)
	assert_bool(result1).is_false()

	var result2: bool = hot_dog_manager.sell_hot_dogs(-3)
	assert_bool(result2).is_false()

	assert_int(hot_dog_manager.hot_dogs_inventory).is_equal(initial_inventory)
	assert_int(hot_dog_manager.currency_balance).is_equal(initial_currency)


func test_manual_hot_dogs_per_second():
	"""Test manual hot dog production rate estimation"""
	hot_dog_manager.hot_dogs_per_click = 2
	
	var manual_rate = hot_dog_manager.get_hot_dogs_per_second_manual()
	# 2 hot dogs per click * 0.5 clicks per second = 1.0 hot dogs/second
	assert_float(manual_rate).is_equal(1.0)


func test_rate_calculations_exist():
	"""Test that all rate calculation methods exist and don't crash"""
	# Test that methods exist and return valid numbers
	var currency_rate = hot_dog_manager.get_currency_per_second()
	assert_float(currency_rate).is_greater_equal(0.0)
	
	var manual_rate = hot_dog_manager.get_hot_dogs_per_second_manual()
	assert_float(manual_rate).is_greater_equal(0.0)
	
	var worker_rate = hot_dog_manager.get_hot_dogs_per_second_workers()
	assert_float(worker_rate).is_greater_equal(0.0)
	
	var total_rate = hot_dog_manager.get_hot_dogs_per_second_total()
	assert_float(total_rate).is_greater_equal(0.0)
	
	var consumption_rate = hot_dog_manager.get_hot_dog_consumption_per_second()
	assert_float(consumption_rate).is_greater_equal(0.0)
	
	var net_rate = hot_dog_manager.get_net_hot_dog_rate()
	# Net rate can be negative (consumption > production), just test it's a valid number
	assert_that(net_rate).is_not_null()
