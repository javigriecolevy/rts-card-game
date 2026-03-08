extends ActiveEnchantment
class_name CantAttackEnchantment

# Absorbs first instance of damage
func on_tick(entity_id: int, game_state: GameState) -> void:
	var entity: Entity = game_state.entities.get(entity_id)
	print("CANT ATTACK")
	if entity.can_attack(game_state.tick):
		entity.ready_at_tick = game_state.tick + 1
