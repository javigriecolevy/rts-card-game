extends Effect
class_name DrawCardEffect

# -------------------------
# Config
@export var amount : int = 1

# -------------------------
# makes target_id draw cards equal to amount
func apply_effect(game_state: GameState, target_id: int) -> void:
	if game_state.entities.get(source_player_id) is Hero:
		game_state.event_resolver.add_event(
		DrawCardEvent.new(
			source_player_id,
			game_state.tick
		)
	)
	
