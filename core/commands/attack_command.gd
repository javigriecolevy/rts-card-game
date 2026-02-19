extends GameCommand
class_name AttackCommand

var attacker_id: int
var target_id: int

func _init(_tick: int, _attacker_id: int, _target_id: int) -> void:
	tick = _tick
	attacker_id = _attacker_id
	target_id = _target_id
