extends Effect
class_name SelectRandomTargetEffect

# -------------------------
# Config
@export var target_type: Targeting.TargetType
@export var effect: Effect

# -------------------------
# Applies the wrapped effect a random number of times (between min and max amount values)
func apply_effect(game_state: GameState, _target: int) -> void:
	var select_valid_targets = Targeting.get_valid_targets(source_player_id, target_type, [], game_state)
	select_valid_targets.erase(source_entity_id)
	if select_valid_targets.size() > 0:
		effect = effect.duplicate()
		var random_target = select_valid_targets[game_state.rng.randi_range(0, select_valid_targets.size() - 1)]
		effect.source_player_id = source_player_id
		effect.source_entity_id = source_entity_id
		effect.apply_effect(game_state, random_target)
