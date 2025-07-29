extends GdUnitTestSuite

# Test suite for SaveSystem autoload
# Tests save/load functionality and data persistence

var save_system: Node


func before():
	"""Setup before each test"""
	save_system = get_node("/root/SaveSystem")


func test_save_system_exists():
	"""Test that SaveSystem autoload exists and is accessible"""
	assert_object(save_system).is_not_null()


func test_get_default_save_data():
	"""Test that default save data structure is correct"""
	var default_data: Dictionary = save_system.get_default_save_data()

	assert_dict(default_data).is_not_empty()
	assert_dict(default_data).contains_keys(["hot_dogs", "currency", "upgrades"])


func test_save_data_structure():
	"""Test save data contains expected fields"""
	var save_data: Dictionary = save_system.get_save_data()

	# Test top-level structure
	assert_dict(save_data).contains_key("hot_dogs")
	assert_dict(save_data).contains_key("currency")
	assert_dict(save_data).contains_key("upgrades")

	# Test hot_dogs structure
	var hot_dogs_data: Dictionary = save_data["hot_dogs"]
	assert_dict(hot_dogs_data).contains_key("inventory")
	assert_dict(hot_dogs_data).contains_key("per_click")

	# Test currency structure
	var currency_data: Dictionary = save_data["currency"]
	assert_dict(currency_data).contains_key("balance")
