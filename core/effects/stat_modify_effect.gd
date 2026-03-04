extends Effect
class_name StatModifyEffect

# -------------------------
# Config
@export var attack: int = 0
@export var health: int = 0


# -------------------------
# Add stat values to enchantments
func apply_effect(game_state: GameState, target_id: int) -> void:
	var target = game_state.entities.get(target_id)
	if target == null or target is not Minion:
		return
	
	target.enchantments[Enchant.Type.ATTACK_MOD] = target.enchantments.get(Enchant.Type.ATTACK_MOD, 0) + attack
	target.enchantments[Enchant.Type.HEALTH_MOD] = target.enchantments.get(Enchant.Type.HEALTH_MOD, 0) + health
