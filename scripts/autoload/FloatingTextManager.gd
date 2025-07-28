extends Node

# Floating text manager for hot dog store idle game
# Uses intentional naming conventions for future maintainability

const FLOATING_TEXT_SCENE = preload("res://scenes/ui/FloatingText.tscn")
const POOL_SIZE = 10

var floating_text_pool: Array[Node] = []
var active_floating_texts: Array[Node] = []

func _ready():
	print("FloatingTextManager: Initialized")
	_setup_floating_text_pool()
	print("FloatingTextManager: Pool setup complete, pool size: ", floating_text_pool.size())

func _setup_floating_text_pool():
	"""Setup object pool for floating text instances"""
	for i in range(POOL_SIZE):
		var floating_text = FLOATING_TEXT_SCENE.instantiate()
		floating_text_pool.append(floating_text)
		add_child(floating_text)
	
	print("FloatingTextManager: Created %d floating text instances" % POOL_SIZE)

func _get_floating_text() -> Node:
	"""Get a floating text instance from the pool"""
	if floating_text_pool.size() > 0:
		var floating_text = floating_text_pool.pop_back()
		active_floating_texts.append(floating_text)
		return floating_text
	else:
		# Create a new one if pool is empty
		var floating_text = FLOATING_TEXT_SCENE.instantiate()
		add_child(floating_text)
		active_floating_texts.append(floating_text)
		return floating_text

func _return_floating_text(floating_text: Node):
	"""Return a floating text instance to the pool"""
	if active_floating_texts.has(floating_text):
		active_floating_texts.erase(floating_text)
		floating_text_pool.append(floating_text)
		floating_text.visible = false

func show_hot_dog_gain(amount: int, target_position: Vector2):
	"""Show floating text for hot dog gain near the hot dog display"""
	var floating_text = _get_floating_text()
	if not floating_text:
		print("ERROR: FloatingTextManager: Could not get floating text from pool!")
		return
	
	# Position near the hot dog display (centered above it)
	var display_position = target_position + Vector2(0, -50)
	
	floating_text.show_hot_dog_gain(amount, display_position)
	
	# The floating text will automatically return to pool when animation completes

func show_currency_gain(amount: int, target_position: Vector2):
	"""Show floating text for currency gain near the currency display"""
	var floating_text = _get_floating_text()
	if not floating_text:
		print("ERROR: FloatingTextManager: Could not get floating text from pool!")
		return
	
	# Position near the currency display (centered above it)
	var display_position = target_position + Vector2(0, -50)
	
	floating_text.show_currency_gain(amount, display_position)
	
	# The floating text will automatically return to pool when animation completes 