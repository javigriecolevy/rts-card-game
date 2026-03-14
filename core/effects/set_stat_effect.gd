extends Effect
class_name SetStatEffect

# -------------------------
# Config
@export var attack : int = -1
@export var health : int = -1

# -------------------------
# adds the attack and health values to the minions stats as buffs
func apply_effect(game_state: GameState, target_id: int) -> void:
	if target_id == -1:
		return
	
	if game_state.entities.get(target_id) is Minion:
		if health > -1:
			var hp_mod : StatEnchantment = StatEnchantment.new(StatEnchantment.StatType.HEALTH, StatEnchantment.Mode.SET, health)
			game_state.enchantment_manager.apply_enchantment(target_id, hp_mod)
		if attack > -1:
			var atk_mod : StatEnchantment = StatEnchantment.new(StatEnchantment.StatType.ATTACK, StatEnchantment.Mode.SET, attack)
			game_state.enchantment_manager.apply_enchantment(target_id, atk_mod)
