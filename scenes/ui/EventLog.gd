extends Control

signal event_log_closed()

@onready var event_list_container = $EventContainer/EventList/EventListContainer
@onready var close_button = $EventContainer/Header/CloseButton
@onready var title_label = $EventContainer/Header/Title

var event_log_manager: Node
var event_item_scene = preload("res://scenes/ui/EventLogItem.tscn")

func _ready():
	event_log_manager = get_node("/root/EventLogManager")
	
	# Connect signals
	close_button.pressed.connect(_on_close_button_pressed)
	event_log_manager.event_log_updated.connect(_on_event_log_updated)
	
	# Initial population
	_populate_event_list()
	
	# Hide by default
	visible = false

func _on_close_button_pressed():
	visible = false
	emit_signal("event_log_closed")

func _on_event_log_updated():
	_populate_event_list()

func _populate_event_list():
	"""Populate the event list with recent events"""
	# Clear existing items
	for child in event_list_container.get_children():
		child.queue_free()
	
	# Get recent events (last 20)
	var recent_events = event_log_manager.get_recent_events(20)
	
	# Add events in reverse order (newest first)
	for i in range(recent_events.size() - 1, -1, -1):
		var event = recent_events[i]
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

func _input(event):
	"""Handle input for closing the event log"""
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed() 