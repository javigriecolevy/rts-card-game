extends Effect
class_name RandomRepeatEffect

# -------------------------
# Config
@export var min_amount: int = 2
@export var max_amount: int = 4
@export var effect: Effect

# -------------------------
# Applies the wrapped effect a random number of times (between min and max amount values)
func apply_effect(game_state: GameState, _target: int) -> void:
	effect.source_player_id = source_player_id
	effect.source_entity_id = source_entity_id
	for i in range (game_state.rng.randi_range(min_amount, max_amount)):
		effect.apply_effect(game_state, _target)
