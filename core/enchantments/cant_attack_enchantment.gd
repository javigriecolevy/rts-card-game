extends ActiveEnchantment
class_name CantAttackEnchantment

# Makes entity not able to attack without changing its attack cooldown
func on_tick(entity_id: int, game_state: GameState) -> void:
	var entity: Entity = game_state.entities.get(entity_id)
	if entity.can_attack(game_state.tick):
		entity.ready_at_tick = game_state.tick + 1
