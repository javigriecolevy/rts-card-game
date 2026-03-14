extends Effect
class_name GiveDivineShieldEffect

# -------------------------
# Config
@export var duration_amount: int = -1
const TICKS_PER_SECOND = 100
# -------------------------
# gives target minion the burned enchantment
func apply_effect(game_state: GameState, target_id: int) -> void:
	if target_id == -1:
		return
	
	var divine_shield: DivineShieldEnchantment = DivineShieldEnchantment.new()
	if duration_amount != -1:
		divine_shield.expires_at_tick = game_state.tick + (duration_amount * TICKS_PER_SECOND)
	game_state.enchantment_manager.apply_enchantment(target_id, divine_shield)
