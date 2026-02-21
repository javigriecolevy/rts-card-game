extends Effect
class_name SummonEffect

# -------------------------
# Config
@export var card: CardInfo

# -------------------------
# Summon minion
func apply_effect(game_state: GameState, _target: int) -> void:
	var minion: Minion = Minion.new_from_card(card, source_player_id, game_state.tick)
	game_state.event_resolver.add_event(
		SummonEvent.new(
			source_player_id,
			card.id,
			game_state.tick,
			false,
			-1
		)
	)
