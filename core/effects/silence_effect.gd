extends Effect
class_name SilenceEffect

# -------------------------
# Removes all effects and enchantments from target and enchants with silenced
func apply_effect(game_state: GameState) -> void:
	if target_id == -1:
		return
	
	var target: Entity = game_state.entities.get(target_id)
	target.enchantments.clear()
	if target is Minion:
		target.effects.clear()
		game_state.enchantment_manager.mark_dirty(target_id)
