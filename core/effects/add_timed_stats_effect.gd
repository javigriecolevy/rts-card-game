extends Effect
class_name AddTimedStatsEffect

# -------------------------
# Config
@export var attack: int = 0
@export var health: int = 0
@export var duration: float = 0

# -------------------------
# adds the attack and health values to the minions stats as buffs for the duration
func apply_effect(game_state: GameState, target_id: int) -> void:
	if game_state.entities.get(target_id) is Minion:
		var hp_mod: StatEnchantment = StatEnchantment.new(StatEnchantment.StatType.HEALTH, StatEnchantment.Mode.ADD, health)
		hp_mod.expires_at_tick = game_state.tick + int(duration * 100)
		game_state.enchantment_manager.apply_enchantment(target_id, hp_mod)
		var atk_mod: StatEnchantment = StatEnchantment.new(StatEnchantment.StatType.ATTACK, StatEnchantment.Mode.ADD, attack)
		atk_mod.expires_at_tick = game_state.tick + int(duration * 100)
		game_state.enchantment_manager.apply_enchantment(target_id, atk_mod)
