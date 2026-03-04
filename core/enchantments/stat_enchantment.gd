extends Enchantment
class_name StatEnchantment

enum StatType { ATTACK, HEALTH }

enum Mode { ADD, SET, MULT }

var stat : StatType
var mode : Mode
var value : int

func _init(_stat: StatType, _mode: Mode, _value: int) -> void:
	stat = _stat
	mode = _mode
	value = _value
