extends Effect
class_name SilenceEffect

# -------------------------
# Config

# -------------------------
# Add stat values to enchantments
func apply_effect(game_state: GameState, target_id: int) -> void:
	var target: Entity = game_state.entities.get(target_id)
	if target == null or target is not Minion:
		return
	target.enchantments.clear()
	target.effects.clear()
