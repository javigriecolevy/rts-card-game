# res://game/commands/PlayCardCommand.gd
extends GameCommand
class_name PlayCardCommand

var card_instance_id: int
var target_id: int = -1

func _init(_tick: int = -1, _player_id: int = -1, _card_instance_id: int = -1, _target_id: int = -1) -> void:
	tick = _tick
	player_id = _player_id
	card_instance_id = _card_instance_id
	target_id = _target_id
