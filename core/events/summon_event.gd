extends GameEvent
class_name SummonEvent

var player_id: int
var card_db_id: String
var from_play: bool = false
var battlecry_target_id: int = -1


func _init(_player_id: int = -1, _card_db_id: String = "", _tick: int = -1, _from_play: bool = -1, _bc_target_id: int = -1) -> void:
	player_id = _player_id
	card_db_id = _card_db_id
	tick = _tick
	from_play = _from_play
	battlecry_target_id = _bc_target_id



#var minion: Minion = Minion.new_from_card(game_state.card_instances[event.card_instance_id].definition, player_id, game_state.tick)
