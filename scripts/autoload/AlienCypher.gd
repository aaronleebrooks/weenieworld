extends Node

# Alien Cypher System for "Alien Hot Dog Food Truck"
# Transforms customer/human text into alien text using Caesar cipher

# Cypher configuration
var cypher_offset: int = 7  # Default offset for the Caesar cipher
var cypher_enabled: bool = true  # Whether cypher is active

# Character sets for different intensity levels
var intensity_levels: Dictionary = {
	1: ["a", "e", "i", "o", "u"],
	2:
	[  # Vowels only (subtle)
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z"
	],
	3:
	[  # All letters (moderate)
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
		"0",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9"
	]  # Letters + numbers (extreme)
}

var current_intensity: int = 2  # Default to moderate level


func _ready():
	print("AlienCypher: Initialized")


# Transform text using Caesar cipher: (letter_position + offset) % 26 then (result - offset) % 26
func transform_text(text: String, intensity: int = -1) -> String:
	"""Transform text into alien cypher"""
	if not cypher_enabled or text.is_empty():
		return text

	if intensity == -1:
		intensity = current_intensity

	var result = ""
	var char_set = intensity_levels.get(intensity, intensity_levels[2])

	for char in text:
		var lower_char = char.to_lower()
		var is_upper = char != lower_char

		# Check if character should be transformed
		if char_set.has(lower_char):
			# Get character position in alphabet (0-25 for letters, 26+ for numbers)
			var char_pos = _get_character_position(lower_char)
			if char_pos >= 0:
				# Apply cypher: (position + offset) % 26 then (result - offset) % 26
				var first_step = (char_pos + cypher_offset) % 26
				var second_step = (first_step - cypher_offset) % 26
				if second_step < 0:
					second_step += 26

				# Convert back to character
				var transformed_char = _get_character_from_position(second_step, lower_char)
				result += transformed_char.to_upper() if is_upper else transformed_char
			else:
				result += char
		else:
			result += char

	return result


func _get_character_position(char: String) -> int:
	"""Get the position of a character in the alphabet (0-25)"""
	if char.length() != 1:
		return -1

	var code = char.unicode_at(0)

	# Handle letters (a-z, A-Z)
	if code >= 97 and code <= 122:  # lowercase a-z
		return code - 97
	elif code >= 65 and code <= 90:  # uppercase A-Z
		return code - 65
	# Handle numbers (0-9)
	elif code >= 48 and code <= 57:  # 0-9
		return code - 48 + 26  # Numbers start at position 26

	return -1


func _get_character_from_position(pos: int, original_char: String) -> String:
	"""Get character from position, preserving original type (letter vs number)"""
	if pos < 0 or pos > 35:
		return original_char

	if pos < 26:  # Letters
		return char(pos + 97)  # Convert to lowercase letter
	else:  # Numbers
		return char(pos - 26 + 48)  # Convert to number


# Set cypher intensity level
func set_intensity(level: int):
	"""Set the cypher intensity level (1-3)"""
	if level >= 1 and level <= 3:
		current_intensity = level
		print("AlienCypher: Intensity set to ", level)


# Enable/disable cypher
func set_enabled(enabled: bool):
	"""Enable or disable the alien cypher"""
	cypher_enabled = enabled
	print("AlienCypher: ", "enabled" if enabled else "disabled")


# Set cypher offset
func set_offset(offset: int):
	"""Set the cypher offset value"""
	cypher_offset = offset
	print("AlienCypher: Offset set to ", offset)


# Get current settings
func get_settings() -> Dictionary:
	"""Get current cypher settings"""
	return {"enabled": cypher_enabled, "intensity": current_intensity, "offset": cypher_offset}


# Test function for debugging
func test_cypher():
	"""Test the cypher with sample text"""
	var test_texts = [
		"Hello World",
		"Customer order: 2 hot dogs",
		"Please wait in line",
		"Thank you for your business"
	]

	print("AlienCypher: Testing cypher...")
	for text in test_texts:
		var transformed = transform_text(text)
		print("Original: ", text)
		print("Alien: ", transformed)
		print("---")
