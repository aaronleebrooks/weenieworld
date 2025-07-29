extends Node

signal event_added(event: Dictionary)
signal event_log_updated

# Event types for categorization
enum EventType { PURCHASE, SAVE, RANDOM_EVENT, SYSTEM, WORKER, NOTIFICATION }  # Upgrades, office, workers, etc.  # Manual saves  # Random events and achievements  # System events (game start, etc.)  # Worker-related events  # General notifications

# Event log storage
var event_log: Array[Dictionary] = []
var max_events: int = 50  # Keep last 50 events

# Event templates for common events
var event_templates: Dictionary = {
	"office_purchased":
	{
		"type": EventType.PURCHASE,
		"title": "Office Purchased",
		"description":
		"You've purchased an office! Workers can now be hired and assigned to stations.",
		"icon": "🏢"
	},
	"worker_hired":
	{
		"type": EventType.WORKER,
		"title": "Worker Hired",
		"description": "A new worker has joined your team!",
		"icon": "👷"
	},
	"manual_save":
	{
		"type": EventType.SAVE,
		"title": "Game Saved",
		"description": "Your progress has been saved.",
		"icon": "💾"
	},
	"upgrade_purchased":
	{
		"type": EventType.PURCHASE,
		"title": "Upgrade Purchased",
		"description": "An upgrade has been purchased!",
		"icon": "⬆️"
	}
}


func _ready():
	print("EventLogManager: Initialized")
	# Add initial system event
	add_system_event("Game Started", "Welcome to Alien Hot Dog Food Truck!")


func add_event(
	event_type: EventType,
	title: String,
	description: String,
	icon: String = "📝",
	data: Dictionary = {}
):
	"""Add a new event to the log"""
	var event = {
		"type": event_type,
		"title": title,
		"description": description,
		"icon": icon,
		"timestamp": Time.get_datetime_string_from_system(),
		"data": data
	}

	event_log.append(event)

	# Keep only the last max_events
	if event_log.size() > max_events:
		event_log.pop_front()

	print("EventLogManager: Added event - %s: %s" % [title, description])
	emit_signal("event_added", event)
	emit_signal("event_log_updated")


func add_purchase_event(item_name: String, cost: int, item_type: String = "item"):
	"""Add a purchase event"""
	var title = "%s Purchased" % item_name
	var description = "Purchased %s for %d currency" % [item_name, cost]
	var icon = "💰"

	add_event(
		EventType.PURCHASE,
		title,
		description,
		icon,
		{"item_name": item_name, "cost": cost, "item_type": item_type}
	)


func add_save_event(save_type: String = "manual"):
	"""Add a save event"""
	var title = "Game Saved"
	var description = "Progress saved successfully"
	var icon = "💾"

	add_event(EventType.SAVE, title, description, icon, {"save_type": save_type})


func add_random_event(title: String, description: String, icon: String = "🎲"):
	"""Add a random event"""
	add_event(EventType.RANDOM_EVENT, title, description, icon)


func add_system_event(title: String, description: String, icon: String = "⚙️"):
	"""Add a system event"""
	add_event(EventType.SYSTEM, title, description, icon)


func add_worker_event(title: String, description: String, icon: String = "👷"):
	"""Add a worker-related event"""
	add_event(EventType.WORKER, title, description, icon)


func add_notification(title: String, description: String, icon: String = "📢"):
	"""Add a general notification"""
	add_event(EventType.NOTIFICATION, title, description, icon)


func get_recent_events(count: int = 10) -> Array[Dictionary]:
	"""Get the most recent events"""
	var start_index = max(0, event_log.size() - count)
	return event_log.slice(start_index)


func get_events_by_type(event_type: EventType) -> Array[Dictionary]:
	"""Get all events of a specific type"""
	var filtered_events: Array[Dictionary] = []
	for event in event_log:
		if event["type"] == event_type:
			filtered_events.append(event)
	return filtered_events


func clear_event_log():
	"""Clear all events from the log"""
	event_log.clear()
	emit_signal("event_log_updated")
	print("EventLogManager: Event log cleared")


func get_event_count() -> int:
	"""Get the total number of events in the log"""
	return event_log.size()


func get_event_count_by_type(event_type: EventType) -> int:
	"""Get the count of events of a specific type"""
	var count = 0
	for event in event_log:
		if event["type"] == event_type:
			count += 1
	return count


# Save/Load integration
func get_save_data() -> Dictionary:
	"""Get event log data for saving"""
	return {"event_log": event_log, "max_events": max_events}


func load_save_data(data: Dictionary):
	"""Load event log data from save"""
	if data.has("event_log"):
		event_log = data["event_log"]
	if data.has("max_events"):
		max_events = data["max_events"]

	print("EventLogManager: Loaded %d events from save" % event_log.size())
	emit_signal("event_log_updated")
