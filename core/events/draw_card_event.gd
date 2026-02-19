extends GameEvent
class_name DrawCardEvent

var player_id: int
var card_instance_id: int = -1

func _init(_player_id: int, _tick: int) -> void:
	player_id = _player_id
	tick = _tick
