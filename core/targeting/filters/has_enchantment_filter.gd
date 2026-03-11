extends TargetFilter
class_name HasEnchantmentFilter

@export var enchantment_type: Script

func _init(_enchantment_type: Script) -> void:
	enchantment_type = _enchantment_type

func passes(entity: Entity) -> bool:
	for e in entity.enchantments:
		if e.get_script() == enchantment_type:
			return true
	
	return false
