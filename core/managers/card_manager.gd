extends RefCounted
class_name CardManager

var game_state: GameState

func _init(_game_state: GameState) -> void:
	game_state = _game_state

# -------------------------
# Draw a card 
func handle_draw_card(event: DrawCardEvent) -> void:
	var player_id = event.player_id
	var card: CardInfo = game_state.decks[player_id].draw()
	
	if card == null:
			print("Player %d deck is empty" % player_id)

			var hero_id: int = game_state.heroes[player_id]

			var damage_event: DamageEvent = DamageEvent.new(
				hero_id,
				hero_id, 
				1, # TODO: scale fatigue later
				#DamageEvent.DamageSourceType.FATIGUE,
				game_state.tick
			)

			game_state.event_resolver.add_event(damage_event)

			event.cancelled = true
			return

	var instance: CardInstance = CardInstance.new()
	instance.id = game_state._allocate_card_instance_id()
	instance.definition = card
	instance.owner_id = player_id
	
	event.card_instance_id = instance.id
	
	game_state.card_instances[instance.id] = instance
	game_state.hands[player_id].append(instance.id)

	print("Player %d draws %s"
		% [player_id, card.display_name])

func handle_play_card(event: PlayCardEvent) -> void:
	var card_instance_id = event.card_instance_id
	var player_id = event.player_id
	var target_id = event.target_id

	var card_instance: CardInstance = game_state.card_instances.get(card_instance_id)
	var card: CardInfo = card_instance.definition

	# -------------------------
	# Pay cost & remove from hand
	game_state.mana[player_id] -= card.cost
	game_state.hands[player_id].erase(card_instance_id)

	print("Player %d plays %s"
		% [player_id, card.display_name])

	# -------------------------
	# Resolve card
	match card.type:
		card.CardType.MINION:
			var minion: Minion = Minion.new_from_card(game_state.card_instances[event.card_instance_id].definition, player_id, game_state.tick)
			var summon_minion: SummonEvent = SummonEvent.new(player_id, minion, game_state.tick, true, target_id)
			game_state.event_resolver.add_event(summon_minion)

		card.CardType.SPELL:
			#TODO play spell with target_id
			for effect in card.effects:
				effect.source_player_id = player_id
				effect.apply_effect(game_state, -1)

	# -------------------------
	# Cleanup
	game_state.card_instances.erase(card_instance_id)

func draw_for_all_players() -> void:
	for pid in game_state.decks.keys():
		handle_draw_card(DrawCardEvent.new(pid, game_state.tick))
