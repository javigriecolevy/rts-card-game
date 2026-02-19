extends GameEvent
class_name DeathEvent

var entity_id: int
var name: String

func _init(_entity_id: int, _name: String, _tick: int) -> void:
	entity_id = _entity_id
	name = _name
	tick = _tick
