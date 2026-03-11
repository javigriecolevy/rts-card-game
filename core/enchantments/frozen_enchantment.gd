extends ActiveEnchantment
class_name FrozenEnchantment

# Frozen entities cant attack and its attack cooldown timer doesnt go down
func on_tick(entity_id: int, game_state: GameState) -> void:
	var entity: Entity = game_state.entities.get(entity_id)
	entity.ready_at_tick = entity.ready_at_tick + 1
	var cant_attack_enchant: ActiveEnchantment = CantAttackEnchantment.new()
	cant_attack_enchant.expires_at_tick = game_state.tick + 1
	game_state.enchantment_manager.apply_enchantment(entity_id, cant_attack_enchant)
