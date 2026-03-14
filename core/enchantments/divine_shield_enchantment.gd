extends ActiveEnchantment
class_name DivineShieldEnchantment

func _init() -> void:
	stackable = false

# Absorbs first instance of damage
func on_damage_taken(_entity_id: int, game_state: GameState, _damage: int) -> int:
	expires_at_tick = game_state.tick
	game_state.enchantment_manager.mark_dirty(_entity_id)
	return 0
