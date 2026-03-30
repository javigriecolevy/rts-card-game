extends Resource
class_name EffectTrigger

func should_trigger(event: GameEvent) -> bool:
	return false # Override in subclasses to define behavior
