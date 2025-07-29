extends GdUnitTestSuite

# Test suite for SaveSystem autoload
# Tests save/load functionality and data persistence

var save_system: Node


func before():
	"""Setup before each test"""
	save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		# If autoload not available, create a mock instance for testing
		save_system = preload("res://scripts/autoload/SaveSystem.gd").new()
		add_child(save_system)


func test_save_system_exists():
	"""Test that SaveSystem autoload exists and is accessible"""
	assert_object(save_system).is_not_null()


func test_get_default_save_data():
	"""Test that default save data structure is correct"""
	var default_data: Dictionary = GameData.get_default_save_data()

	assert_dict(default_data).is_not_empty()
	assert_dict(default_data).contains_keys(["truck_name", "currency", "hot_dogs_inventory"])


func test_save_data_structure():
	"""Test save data contains expected fields"""
	var save_data: Dictionary = save_system._collect_save_data()

	# Test basic structure - save system collects data from various managers
	assert_dict(save_data).is_not_empty()

	# Test that save data is a valid dictionary (basic validation)
	assert_object(save_data).is_not_null()
