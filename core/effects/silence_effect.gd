extends Effect
class_name SilenceEffect

# -------------------------
# Config

# -------------------------
# Add stat values to enchantments
func apply_effect(game_state: GameState, target_id: int) -> void:
	var target: Entity = game_state.entities.get(target_id)
	if target is Minion:
		target.enchantments.clear()
		target.effects.clear()
		game_state.enchantment_manager.mark_dirty(target_id)
