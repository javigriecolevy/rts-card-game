extends GameEvent
class_name DeathEvent

var entity_id: int
var killing_blow: DamageEvent.DAMAGE_REASON = DamageEvent.DAMAGE_REASON.COMBAT

func _init(_entity_id: int = -1,  
			_tick: int = -1,
			_killing_blow: DamageEvent.DAMAGE_REASON = DamageEvent.DAMAGE_REASON.COMBAT) -> void:
	entity_id = _entity_id
	killing_blow = _killing_blow
	tick = _tick
