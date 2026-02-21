extends Control
class_name HandView

# Container where cards will be added
@onready var card_container: VBoxContainer = $CardContainer

# Preload the CardView scene
@onready var CardViewScene: PackedScene = preload("res://scenes/ui/card_view.tscn")

# Reference to your game state
var game_state: GameState

# Track cards currently displayed
var cards: Array[int] = []

# Re-emitted signal for parent (GameView) to listen to
signal card_selected(card_id: int)


# -------------------------
# Setup
func setup(_game_state: GameState) -> void:
	game_state = _game_state


# -------------------------
# Called when hand changes
func update_hand(new_cards: Array[int]) -> void:
	cards = new_cards
	_refresh()


# -------------------------
# Rebuild UI
func _refresh() -> void:
	# Clear old cards safely
	for child in card_container.get_children():
		child.queue_free()

	# Add current cards
	for card_instance_id in cards:
		var instance = game_state.card_instances[card_instance_id]

		var card_view: CardView = CardViewScene.instantiate()
		card_view.setup(instance.id, instance.definition)

		# Connect child → parent
		card_view.card_clicked.connect(_on_card_clicked)

		card_container.add_child(card_view)


# -------------------------
# Child signal handler
func _on_card_clicked(card_id: int) -> void:
	print("HandView detected card:", card_id)

	# Re-emit upward
	card_selected.emit(card_id)
