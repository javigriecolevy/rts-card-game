extends TargetFilter
class_name StatFilter

enum Comparison {
	LESS,
	GREATER,
	EQUAL
}
enum StatType {
	ATTACK,
	HEALTH
}

@export var stat: StatType
@export var value: int
@export var comparison: Comparison


func passes(entity: Entity) -> bool:
	var stat_value
	
	match stat:
		StatType.ATTACK:
			stat_value = entity.attack
		StatType.HEALTH:
			stat_value = entity.health
	
	match comparison:
		Comparison.LESS:
			return stat_value < value
		Comparison.GREATER:
			return stat_value > value
		Comparison.EQUAL:
			return stat_value == value
	
	return false
