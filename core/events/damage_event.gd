extends GameEvent
class_name DamageEvent

var source_id: int
var target_id: int
var amount: int
var reason: int

enum DAMAGE_REASON {
	COMBAT,
	SPELL,
	BURN,
	DOOM
}

func _init(_source_id: int = -1, 
		_target_id: int = -1, 
		_amount: int = -1,
		_tick: int = -1,
		_reason: DAMAGE_REASON = DAMAGE_REASON.COMBAT,
		) -> void:
	source_id = _source_id
	target_id = _target_id
	amount = _amount
	reason = _reason
	tick = _tick
