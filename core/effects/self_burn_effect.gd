extends Effect
class_name SelfBurnEffect

# -------------------------
# Config
@export var duration_amount : int = 0

# -------------------------
# adds the attack and health values to the minions stats as buffs
func apply_effect(game_state: GameState, _target_id: int) -> void:
	if game_state.entities.get(source_player_id) is Hero:
		var burn: BurnedEnchantment = BurnedEnchantment.new()
		burn.duration = duration_amount
		burn.expires_at_tick = game_state.tick + (duration_amount * burn.TICKS_PER_SECOND)
		game_state.enchantment_manager.apply_enchantment(source_player_id, burn)
