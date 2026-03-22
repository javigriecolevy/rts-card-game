extends Effect
class_name SummonRandom2CostEffect

# -------------------------
# Summon minion
func apply_effect(game_state: GameState, _target: int) -> void:
	var cost_bitset: CardBitset = card_database.get_bitset_by_cost(2)
	var class_bitset: CardBitset = card_database.get_bitset_by_class(CardAttributes.CLASS.NEUTRAL)
	var filtered = cost_bitset #& class_bitset
	var card: CardInfo = card_database.get_random_card_from_bitset(filtered, game_state.rng)
	if card is MinionCardInfo:
		game_state.event_resolver.add_event(
			SummonEvent.new(
				source_player_id,
				card.id,
				game_state.tick,
				false,
				-1
			)
		)
