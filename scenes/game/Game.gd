extends Control

@onready var back_button = $BackButton
@onready var hello_world_label = $HelloWorldLabel

func _ready():
	# Connect button signals
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Display current game data
	display_game_data()
	
	# Add manual save button for testing
	add_manual_save_button()

func _on_back_button_pressed():
	print("Returning to main menu...")
	get_node("/root/GameManager").return_to_main_menu()

func display_game_data():
	# Show current currency and other game data
	var currency = get_node("/root/GameManager").get_game_data("currency", 0)
	var click_value = get_node("/root/GameManager").get_game_data("click_value", 1)
	
	hello_world_label.text = "Hello World!\nCurrency: %d\nClick Value: %d" % [currency, click_value]

func add_manual_save_button():
	var save_button = Button.new()
	save_button.text = "Manual Save"
	save_button.position = Vector2(20, 100)
	save_button.pressed.connect(_on_manual_save_pressed)
	add_child(save_button)

func _on_manual_save_pressed():
	print("Creating manual save...")
	var success = get_node("/root/SaveSystem").create_manual_save()
	if success:
		print("Manual save created successfully!")
	else:
		print("Failed to create manual save!")

func _input(event):
	# Handle escape key to return to menu
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed() 