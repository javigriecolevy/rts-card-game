extends Effect
class_name AddStatEffect

# -------------------------
# Config
@export var attack : int = 0
@export var health : int = 0

# -------------------------
# adds the attack and health values to the minions stats as buffs
func apply_effect(game_state: GameState, target_id: int) -> void:
	if game_state.entities.get(target_id) is Minion:
		var hp_mod : StatEnchantment = StatEnchantment.new(StatEnchantment.StatType.HEALTH, StatEnchantment.Mode.ADD, health)
		game_state.entities.get(target_id).enchantments.append(hp_mod)
		var atk_mod : StatEnchantment = StatEnchantment.new(StatEnchantment.StatType.ATTACK, StatEnchantment.Mode.ADD, attack)
		game_state.entities.get(target_id).enchantments.append(atk_mod)
