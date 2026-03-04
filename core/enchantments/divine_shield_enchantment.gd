extends ActiveEnchantment
class_name DivineShieldEnchantment

# Absorbs first instance of damage
func on_damage_taken(_entity_id: int, game_state: GameState, _damage: int) -> int:
	expires_at_tick = game_state.current_tick
	return 0
