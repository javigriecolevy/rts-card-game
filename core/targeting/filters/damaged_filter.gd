extends TargetFilter
class_name DamagedFilter

func passes(entity: Entity) -> bool:
	return entity.health < entity.max_health
