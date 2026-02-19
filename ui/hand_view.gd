# HandView.gd
extends Control

# Container where cards will be added
@onready var card_container: VBoxContainer = $CardContainer

# Preload the CardView scene (must be a .tscn)
@onready var CardViewScene: PackedScene = preload("res://scenes/ui/card_view.tscn")

# List of card instance IDs currently in hand
var cards: Array[int] = []

# Reference to your game state
var game_state: GameState

# Signal when a card is clicked
signal card_selected(card_id)

func _init(_game_state: GameState) -> void:
	game_state = _game_state

# Call this whenever your hand changes
func update_hand(new_cards: Array[int]) -> void:
	cards = new_cards
	_refresh_card_views()

# Clears the container and re-adds card views
func _refresh_card_views() -> void:
	card_container.clear()  # Remove old card views

	for card_instance_id in cards:
		var instance = game_state.card_instances[card_instance_id] 
		var card_view: Control = CardViewScene.instantiate()

		card_view.card_instance_id = instance.id
		
		# Connect the "clicked" signal from CardView to this view
		card_view.connect("clicked", Callable(self, "_on_card_clicked"))

		# Add the view to the container
		card_container.add_child(card_view)

# Signal handler when a card is clicked
func _on_card_clicked(card_instance_id: int) -> void:
	print("!!!!! Selected card %d", card_instance_id)
	emit_signal("card_selected", card_instance_id)
