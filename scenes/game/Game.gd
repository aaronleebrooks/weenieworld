extends Control

@onready var back_button = $BackButton
@onready var hello_world_label = $HelloWorldLabel

func _ready():
	# Connect button signals
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Display current game data
	display_game_data()

func _on_back_button_pressed():
	print("Returning to main menu...")
	GameManager.return_to_main_menu()

func display_game_data():
	# Show current currency and other game data
	var currency = GameManager.get_game_data("currency", 0)
	var click_value = GameManager.get_game_data("click_value", 1)
	
	hello_world_label.text = "Hello World!\nCurrency: %d\nClick Value: %d" % [currency, click_value]

func _input(event):
	# Handle escape key to return to menu
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed() 