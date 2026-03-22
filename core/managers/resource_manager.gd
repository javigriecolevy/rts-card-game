extends RefCounted
class_name ResourceManager

var game_state: GameState

func _init(_game_state: GameState) -> void:
	game_state = _game_state

# -------------------------
# Setup players
func setup_players(player_ids: Array, starting_deck: Dictionary[int, Array]) -> void:
	for pid in player_ids:
		# -------------------------
		# Create player deck
		var deck : Deck = _create_starting_deck(pid, starting_deck)
		var hero_card: HeroCardInfo = deck.cards.pop_front()
		
		# -------------------------
		# Create hero entity
		var hero: Hero = Hero.new_hero(hero_card, pid, 30)
		hero.id = game_state._allocate_entity_id()
		hero.owner_id = pid
		hero.display_name = "Hero %d" % pid

		game_state.entities[hero.id] = hero
		game_state.heroes[pid] = hero

		# -------------------------
		# Deck / hand
		game_state.decks[pid] = deck
		game_state.hands[pid] = []

		# -------------------------
		# Mana
		game_state.max_mana[pid] = 0
		game_state.mana[pid] = 0

		# -------------------------
		# Board
		game_state.boards[pid] = []
	
	for i in range(3):
		game_state.event_resolver.card_manager.draw_for_all_players()
# -------------------------
# Starting deck
func _create_starting_deck(player_id: int, starting_decks: Dictionary) -> Deck:
	var card_ids : Array = starting_decks[player_id]
	var cards : Array = []
	
	for id in card_ids:
		cards.append(card_database.get_card_by_id(id))
	
	return Deck.new(cards)

# -------------------------
# Increase mana at the start of a cycle (or turn)
func refresh_mana() -> void:
	for pid in game_state.mana.keys():
		# Increment max mana up to the limit
		if game_state.max_mana[pid] < game_state.max_mana_limit:
			game_state.max_mana[pid] += 1

		# Refill current mana to max mana
		game_state.mana[pid] = game_state.max_mana[pid]

# -------------------------
# Get current mana
func get_mana(player_id: int) -> int:
	return game_state.mana.get(player_id, 0)

# -------------------------
# Get max mana
func get_max_mana(player_id: int) -> int:
	return game_state.max_mana.get(player_id, 0)
