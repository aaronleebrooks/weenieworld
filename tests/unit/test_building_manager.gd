extends GdUnitTestSuite

# Test suite for BuildingManager autoload
# Tests building purchase logic, unlock conditions, and state management

var building_manager: Node
var hot_dog_manager: Node
var mock_save_system: Node


func before():
	"""Setup before each test"""
		building_manager = get_node_or_null("/root/BuildingManager")
	if not building_manager:
		# If autoload not available, create a mock instance for testing
		building_manager = preload("res://scripts/autoload/BuildingManager.gd").new()
		add_child(building_manager)
	
	hot_dog_manager = get_node_or_null("/root/HotDogManager")
	if not hot_dog_manager:
		# Create mock HotDogManager for testing
		hot_dog_manager = preload("res://scripts/autoload/HotDogManager.gd").new()
		add_child(hot_dog_manager)
		building_manager.hot_dog_manager = hot_dog_manager

	# Reset state for clean tests
	building_manager.reset_buildings()
	hot_dog_manager.currency_balance = 0
	hot_dog_manager.total_currency_earned = 0


func test_initial_state():
	"""Test BuildingManager starts with no purchased buildings"""
	assert_bool(building_manager.is_building_purchased("office")).is_false()
	assert_int(building_manager.get_purchased_building_count()).is_equal(0)


func test_get_building_definitions():
	"""Test that building definitions are loaded"""
	var buildings = building_manager.get_all_buildings()
	assert_int(buildings.size()).is_greater(0)

	# Check office building exists
	var office_building = null
	for building in buildings:
		if building.building_id == "office":
			office_building = building
			break

	assert_object(office_building).is_not_null()
	assert_str(office_building.display_name).is_equal("Office")
	assert_int(office_building.base_cost).is_equal(500)


func test_unlock_conditions():
	"""Test building unlock conditions"""
	# Office should be locked initially (need 100 total currency earned)
	assert_bool(building_manager.is_building_unlocked("office")).is_false()

	# Give enough total currency earned
	hot_dog_manager.total_currency_earned = 100
	assert_bool(building_manager.is_building_unlocked("office")).is_true()

	# But still can't purchase without current currency
	assert_bool(building_manager.can_purchase_building("office")).is_false()


func test_purchase_requirements():
	"""Test building purchase requirements"""
	# Setup conditions for office purchase
	hot_dog_manager.total_currency_earned = 100  # Unlock condition
	hot_dog_manager.currency_balance = 500  # Purchase cost

	# Should be able to purchase now
	assert_bool(building_manager.can_purchase_building("office")).is_true()

	# Insufficient currency
	hot_dog_manager.currency_balance = 400
	assert_bool(building_manager.can_purchase_building("office")).is_false()


func test_successful_purchase():
	"""Test successful building purchase"""
	# Setup conditions
	hot_dog_manager.total_currency_earned = 100
	hot_dog_manager.currency_balance = 500

	# Monitor signals using GdUnit4 approach
	var signal_monitor = monitor_signal(building_manager, "building_purchased")

	# Purchase office
	var result = building_manager.purchase_building("office")
	assert_bool(result).is_true()

	# Verify state changes
	assert_bool(building_manager.is_building_purchased("office")).is_true()
	assert_int(building_manager.get_purchased_building_count()).is_equal(1)
	assert_int(hot_dog_manager.currency_balance).is_equal(0)  # 500 - 500

	# Allow one frame for signal processing
	await get_tree().process_frame
	assert_signal(signal_monitor).is_emitted()


func test_cannot_purchase_twice():
	"""Test that buildings cannot be purchased multiple times"""
	# Setup and purchase once
	hot_dog_manager.total_currency_earned = 100
	hot_dog_manager.currency_balance = 1000

	var first_purchase = building_manager.purchase_building("office")
	assert_bool(first_purchase).is_true()

	# Try to purchase again
	var second_purchase = building_manager.purchase_building("office")
	assert_bool(second_purchase).is_false()
	assert_int(hot_dog_manager.currency_balance).is_equal(500)  # Only one purchase


func test_get_building_info():
	"""Test building info retrieval"""
	hot_dog_manager.total_currency_earned = 100
	hot_dog_manager.currency_balance = 300  # Not enough for purchase

	var info = building_manager.get_building_info("office")
	assert_bool(info.has("building")).is_true()
	assert_bool(info.has("is_purchased")).is_true()
	assert_bool(info.has("is_unlocked")).is_true()
	assert_bool(info.has("can_purchase")).is_true()

	assert_bool(info["is_purchased"]).is_false()
	assert_bool(info["is_unlocked"]).is_true()
	assert_bool(info["can_purchase"]).is_false()  # Not enough currency


func test_save_and_load():
	"""Test save and load functionality"""
	# Purchase a building
	hot_dog_manager.total_currency_earned = 100
	hot_dog_manager.currency_balance = 500
	building_manager.purchase_building("office")

	# Get save data
	var save_data = building_manager.get_save_data()
	assert_bool(save_data.has("buildings")).is_true()
	assert_bool(save_data["buildings"]["purchased"].has("office")).is_true()
	assert_bool(save_data["buildings"]["purchased"]["office"]).is_true()

	# Reset and load
	building_manager.reset_buildings()
	assert_bool(building_manager.is_building_purchased("office")).is_false()

	# Simulate loading save data
	building_manager._on_save_data_loaded(save_data)
	assert_bool(building_manager.is_building_purchased("office")).is_true()


func test_reset_buildings():
	"""Test building reset functionality"""
	# Purchase a building
	hot_dog_manager.total_currency_earned = 100
	hot_dog_manager.currency_balance = 500
	building_manager.purchase_building("office")
	assert_bool(building_manager.is_building_purchased("office")).is_true()

	# Reset
	building_manager.reset_buildings()
	assert_bool(building_manager.is_building_purchased("office")).is_false()
	assert_int(building_manager.get_purchased_building_count()).is_equal(0)


func test_nonexistent_building():
	"""Test handling of nonexistent buildings"""
	assert_bool(building_manager.can_purchase_building("nonexistent")).is_false()
	assert_bool(building_manager.purchase_building("nonexistent")).is_false()
	assert_bool(building_manager.is_building_purchased("nonexistent")).is_false()
	assert_bool(building_manager.is_building_unlocked("nonexistent")).is_false()
