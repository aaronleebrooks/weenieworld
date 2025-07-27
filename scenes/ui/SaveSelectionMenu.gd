extends Control

@onready var save_list = $MenuPanel/SaveList
@onready var no_saves_label = $MenuPanel/SaveList/NoSavesLabel
@onready var back_button = $MenuPanel/ButtonContainer/BackButton

var save_buttons = []

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	populate_save_list()

func populate_save_list():
	# Clear existing save buttons
	for button in save_buttons:
		button.queue_free()
	save_buttons.clear()
	
	# Get available save files
	var save_files = get_node("/root/SaveSystem").get_save_files()
	
	if save_files.is_empty():
		no_saves_label.visible = true
		return
	
	no_saves_label.visible = false
	
	# Create buttons for each save file
	for save_info in save_files:
		var save_button = Button.new()
		save_button.text = save_info["name"] + "\n" + save_info["time"]
		save_button.custom_minimum_size = Vector2(0, 60)
		save_button.pressed.connect(_on_save_selected.bind(save_info))
		save_list.add_child(save_button)
		save_buttons.append(save_button)

func _on_save_selected(save_info: Dictionary):
	print("Loading save: ", save_info["name"])
	
	# Load the selected save
	var game_manager = get_node("/root/GameManager")
	game_manager.load_specific_save(save_info)
	
	# Close this menu and go to game
	queue_free()
	get_node("/root/GameManager").change_scene(game_manager.GAME_SCENE)

func _on_back_button_pressed():
	queue_free() 