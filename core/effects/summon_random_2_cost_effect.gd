extends Effect
class_name SummonRandom2CostEffect

# -------------------------
# Summon minion
func apply_effect(game_state: GameState) -> void:
	var cost_bitset: CardBitset = card_database.get_bitset_by_cost(2)
	var class_bitset: CardBitset = card_database.get_bitset_by_class(CardAttributes.CLASS.NEUTRAL)
	var type_bitset: CardBitset = card_database.by_type[CardAttributes.CARDTYPE.MINION]
	var filtered = cost_bitset._and(class_bitset)._and(type_bitset)
	var card: MinionCardInfo = card_database.get_random_card_from_bitset(filtered, game_state.rng)
	game_state.event_resolver.add_event(
			SummonEvent.new(
				source_player_id,
				card.id,
				game_state.tick,
				false,
				-1
			)
		)
