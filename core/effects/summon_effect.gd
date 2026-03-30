extends Effect
class_name SummonEffect

# -------------------------
# Config
@export var card: MinionCardInfo

# -------------------------
# Summon minion
func apply_effect(game_state: GameState) -> void:
	game_state.event_resolver.add_event(
		SummonEvent.new(
			source_player_id,
			card.id,
			game_state.tick,
			false,
			-1
		)
	)
