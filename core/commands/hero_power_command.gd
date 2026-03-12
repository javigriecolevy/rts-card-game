extends GameCommand
class_name HeroPowerCommand

var target_id: int

func _init(_tick: int = -1, _player_id: int = -1, _target_id: int = -1) -> void:
	tick = _tick
	player_id = _player_id
	target_id = _target_id
