extends GameCommand
class_name AdvanceTickCommand

func _init(_tick: int = -1, _player_id: int = -1) -> void:
	tick = _tick
	player_id = _player_id
