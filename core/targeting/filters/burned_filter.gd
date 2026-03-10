extends TargetFilter
class_name BurnedFilter

func passes(entity: Entity) -> bool:
	for e in entity.enchantments:
		if e is BurnedEnchantment:
			return true
	return false
