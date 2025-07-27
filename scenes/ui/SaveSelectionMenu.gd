extends Control

@onready var save_list = $MenuPanel/SaveList/SaveListContainer
@onready var no_saves_label = $MenuPanel/SaveList/SaveListContainer/NoSavesLabel
@onready var back_button = $MenuPanel/ButtonContainer/BackButton

var save_buttons = []
var save_containers = []

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	populate_save_list()

func populate_save_list():
	# Clear existing save containers
	for container in save_containers:
		container.queue_free()
	save_containers.clear()
	save_buttons.clear()
	
	# Get available save files
	var save_files = get_node("/root/SaveSystem").get_save_files()
	
	if save_files.is_empty():
		no_saves_label.visible = true
		return
	
	no_saves_label.visible = false
	
	# Create containers for each save file
	for save_info in save_files:
		var save_container = HBoxContainer.new()
		save_container.custom_minimum_size = Vector2(0, 60)
		
		# Create load button
		var load_button = Button.new()
		load_button.text = save_info["name"] + "\n" + save_info["time"]
		load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		load_button.pressed.connect(_on_save_selected.bind(save_info))
		save_container.add_child(load_button)
		save_buttons.append(load_button)
		
		# Create delete button
		var delete_button = Button.new()
		delete_button.text = "X"
		delete_button.custom_minimum_size = Vector2(40, 0)
		delete_button.pressed.connect(_on_delete_save_pressed.bind(save_info))
		save_container.add_child(delete_button)
		
		save_list.add_child(save_container)
		save_containers.append(save_container)

func _on_save_selected(save_info: Dictionary):
	print("Loading save: ", save_info["name"])
	
	# Load the selected save
	var game_manager = get_node("/root/GameManager")
	game_manager.load_specific_save(save_info)
	
	# Close this menu and go to game
	queue_free()
	get_node("/root/GameManager").change_scene(game_manager.GAME_SCENE)

func _on_delete_save_pressed(save_info: Dictionary):
	show_delete_confirmation(save_info)

func show_delete_confirmation(save_info: Dictionary):
	var dialog_scene = preload("res://scenes/ui/ConfirmationDialog.tscn")
	var dialog = dialog_scene.instantiate()
	dialog.setup(save_info)
	dialog.confirmed.connect(_on_delete_confirmed.bind(save_info))
	dialog.cancelled.connect(_on_delete_cancelled)
	add_child(dialog)

func _on_delete_confirmed(save_info: Dictionary):
	print("Deleting save: ", save_info["name"])
	var success = get_node("/root/SaveSystem").delete_save_file(save_info)
	if success:
		print("Save deleted successfully!")
		populate_save_list()  # Refresh the list
	else:
		print("Failed to delete save!")

func _on_delete_cancelled():
	print("Delete cancelled")

func _on_back_button_pressed():
	queue_free() 