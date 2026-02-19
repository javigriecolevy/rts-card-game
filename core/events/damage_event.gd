extends GameEvent
class_name DamageEvent

var source_id: int
var target_id: int
var amount: int

func _init(_source_id: int, _target_id: int, _amount: int, _tick: int) -> void:
	source_id = _source_id
	target_id = _target_id
	amount = _amount
	tick = _tick
