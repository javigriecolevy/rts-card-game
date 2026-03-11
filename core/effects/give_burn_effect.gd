extends Effect
class_name GiveBurnEffect

# -------------------------
# Config
@export var duration_amount: int = 0

# -------------------------
# gives target minion the burned enchantment
func apply_effect(game_state: GameState, target_id: int) -> void:
	if target_id == -1:
		return
	
	var burn: BurnedEnchantment = BurnedEnchantment.new()
	burn.duration = duration_amount
	game_state.enchantment_manager.apply_enchantment(target_id, burn)
