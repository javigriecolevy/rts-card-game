extends GameEvent
class_name DrawCardEvent

var player_id: int
var card_instance_id: int = -1

func _init(_player_id: int  = -1, _tick: int  = -1) -> void:
	player_id = _player_id
	tick = _tick
