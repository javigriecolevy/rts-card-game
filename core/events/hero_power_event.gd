extends GameEvent
class_name HeroPowerEvent

var player_id: int
var target_id: int

func _init(_player_id: int = -1, _target_id: int = -1, _tick: int = -1) -> void:
	player_id = _player_id
	target_id = _target_id
	tick = _tick
