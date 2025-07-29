extends Panel

@onready var icon_label = $HBoxContainer/Icon
@onready var title_label = $HBoxContainer/ContentContainer/TitleRow/Title
@onready var timestamp_label = $HBoxContainer/ContentContainer/TitleRow/Timestamp
@onready var description_label = $HBoxContainer/ContentContainer/Description

var event_data: Dictionary = {}

func setup_event(event: Dictionary):
	"""Setup the event item with event data"""
	event_data = event
	
	# Set icon
	icon_label.text = event.get("icon", "📝")
	
	# Set title
	title_label.text = event.get("title", "Unknown Event")
	
	# Set description
	description_label.text = event.get("description", "No description available")
	
	# Set timestamp
	var timestamp = event.get("timestamp", "")
	if timestamp:
		# Format timestamp to be more readable
		var formatted_time = _format_timestamp(timestamp)
		timestamp_label.text = formatted_time
	else:
		timestamp_label.text = ""

func _format_timestamp(timestamp: String) -> String:
	"""Format timestamp to be more readable"""
	# Handle UTC timestamp format like "2025-07-28T20:16:00"
	if "T" in timestamp:
		# Parse the UTC timestamp
		var time_parts = timestamp.split("T")
		if time_parts.size() >= 2:
			var time_part = time_parts[1]
			# Remove any trailing timezone info
			if "." in time_part:
				time_part = time_part.split(".")[0]
			
			# Parse hours and minutes
			var time_components = time_part.split(":")
			if time_components.size() >= 2:
				var hour = int(time_components[0])
				var minute = time_components[1]
				
				# Convert to 12-hour format
				var period = "AM"
				if hour >= 12:
					period = "PM"
				if hour > 12:
					hour -= 12
				elif hour == 0:
					hour = 12
				
				return "%d:%s %s" % [hour, minute, period]
	
	# Fallback: return just the time part if it exists
	if " " in timestamp:
		var parts = timestamp.split(" ")
		if parts.size() >= 2:
			return parts[1]  # Return just the time part
	
	return timestamp

func _ready():
	# Set up styling
	_setup_styling()

func _setup_styling():
	"""Setup the visual styling of the event item"""
	# Add some padding and styling
	# This can be enhanced with custom styles later
	pass 
