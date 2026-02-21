extends GameEvent
class_name DeathEvent

var entity_id: int

func _init(_entity_id: int = -1, _tick: int = -1) -> void:
	entity_id = _entity_id
	tick = _tick
