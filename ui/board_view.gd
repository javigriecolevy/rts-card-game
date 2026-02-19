extends Control
class_name BoardView

@export var player_id: int
@onready var minion_container := $MinionContainer

func refresh_board(game_state):
	minion_container.clear()
	for minion in game_state.boards[player_id]:
		var minion_view := MinionView.instantiate()
		minion_view.minion_id = minion.id
		minion_view.display_name = minion.display_name
		minion_container.add_child(minion_view)
