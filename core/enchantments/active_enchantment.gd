extends Enchantment
class_name ActiveEnchantment

# -------------------------------
# Override these hooks in subclasses to define behavior

func on_tick(_entity_id: int, _game_state) -> void:
	pass

func on_damage_taken(_entity_id: int, _game_state, damage: int) -> int:
	return damage

func on_damage_dealt(_entity_id: int, _game_state, _target_id: int) -> void:
	pass
	
func on_attack(_entity_id: int, _game_state, _target_id: int) -> void:
	pass
