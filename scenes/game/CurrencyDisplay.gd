extends Control

@onready var currency_label = $CurrencyLabel

func _ready():
	print("CurrencyDisplay: Initialized")
	
	# Connect to currency changes
	var currency_manager = get_node("/root/CurrencyManager")
	if currency_manager:
		currency_manager.currency_changed.connect(_on_currency_changed)
		currency_manager.currency_gained.connect(_on_currency_gained)
		currency_manager.currency_spent.connect(_on_currency_spent)
		
		# Initial update
		_update_display()
	
	# Connect to viewport size changes for responsive sizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_responsive_layout()

func _on_viewport_size_changed():
	_update_responsive_layout()

func _update_responsive_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate responsive font size (like CSS vw units)
	var font_size_percent = viewport_size.x * 0.02  # 2% of viewport width
	var responsive_font_size = max(14, min(font_size_percent, 32))  # 14px to 32px
	
	if currency_label:
		currency_label.add_theme_font_size_override("font_size", responsive_font_size)
		print("CurrencyDisplay: Font size updated to ", responsive_font_size, "px")

func _on_currency_changed(new_balance: int, change_amount: int):
	_update_display()
	# Only log significant changes (more than 1 currency)
	if abs(change_amount) > 1:
		print("CurrencyDisplay: Currency changed by ", change_amount, " (new balance: ", new_balance, ")")

func _on_currency_gained(amount: int, source: String):
	_update_display()
	# Only log significant gains
	if amount > 1:
		print("CurrencyDisplay: Gained ", amount, " currency from ", source)

func _on_currency_spent(amount: int, reason: String):
	_update_display()
	# Only log significant spending
	if amount > 1:
		print("CurrencyDisplay: Spent ", amount, " currency for ", reason)

func _update_display():
	var currency_manager = get_node("/root/CurrencyManager")
	if currency_manager and currency_label:
		var formatted_currency = currency_manager.get_formatted_currency()
		currency_label.text = formatted_currency
		# Don't log every update - too frequent 