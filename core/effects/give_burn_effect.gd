extends Effect
class_name GiveBurnEffect

# -------------------------
# Config
@export var duration_amount: int = 0

# -------------------------
# adds the attack and health values to the minions stats as buffs
func apply_effect(game_state: GameState, target_id: int) -> void:
	var burn: BurnedEnchantment = BurnedEnchantment.new()
	burn.duration = duration_amount
	game_state.enchantment_manager.apply_enchantment(target_id, burn)
