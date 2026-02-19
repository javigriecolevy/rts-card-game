extends Control

@onready var hand_view: HandView = $HandView
@onready var tick_manager = get_node("/root/TickManager")

var player_id := 1

func _ready():
	hand_view.connect("card_selected", Callable(self, "_on_card_selected"))

	# Initial refresh
	_refresh_ui()

func _process(_delta):
	# Refresh UI each frame for prototype
	_refresh_ui()

func _refresh_ui():
	var game_state = tick_manager.game_state
	var hand_cards = game_state.hands[player_id]
	hand_view.update_hand(hand_cards, game_state)

func _on_card_selected(card_instance_id: int):
	print("Card clicked: ", card_instance_id)

	var game_state = tick_manager.game_state

	var command = PlayCardCommand.new(
		game_state.tick + 1,
		player_id,
		card_instance_id,
		-1 # target for now
	)

	tick_manager.command_queue.append(command)
