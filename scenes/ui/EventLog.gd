extends Control

signal event_log_closed()

@onready var event_list_container = $EventContainer/EventList/EventListContainer
@onready var title_label = $EventContainer/Header/Title

var event_log_manager: Node
var event_item_scene = preload("res://scenes/ui/EventLogItem.tscn")

func _ready():
	event_log_manager = get_node("/root/EventLogManager")
	
	# Connect signals
	event_log_manager.event_log_updated.connect(_on_event_log_updated)
	
	# Initial population
	_populate_event_list()
	
	# Visible by default
	visible = true

func _on_event_log_updated():
	_populate_event_list()

func _populate_event_list():
	"""Populate the event list with recent events"""
	# Clear existing items
	for child in event_list_container.get_children():
		child.queue_free()
	
	# Get recent events (last 20)
	var recent_events = event_log_manager.get_recent_events(20)
	
	# Add events in chronological order (oldest first, newest at bottom)
	for event in recent_events:
		var event_item = event_item_scene.instantiate()
		event_list_container.add_child(event_item)
		event_item.setup_event(event)

func show_event_log():
	"""Show the event log"""
	visible = true
	_populate_event_list()

func hide_event_log():
	"""Hide the event log"""
	visible = false

 