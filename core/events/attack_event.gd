extends GameEvent
class_name AttackEvent

var attacker_id: int
var target_id: int

func _init(_attacker_id: int, _target_id: int, _tick: int) -> void:
	attacker_id = _attacker_id
	target_id = _target_id
	tick = _tick
