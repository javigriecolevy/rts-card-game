extends GameEvent
class_name SummonEvent

var player_id: int
var minion: Minion
var from_play: bool = false
var battlecry_target_id: int = -1


func _init(_player_id: int, _minion: Minion, _tick: int, _from_play: bool, _bc_target_id: int) -> void:
	player_id = _player_id
	minion = _minion
	tick = _tick
	from_play = _from_play
	battlecry_target_id = _bc_target_id
