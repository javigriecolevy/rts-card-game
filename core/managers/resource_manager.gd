extends RefCounted
class_name ResourceManager

var game_state: GameState

func _init(_game_state: GameState) -> void:
	game_state = _game_state

# -------------------------
# Setup players
func setup_players(player_ids: Array, starting_deck_func: Callable) -> void:
	for pid in player_ids:
		# -------------------------
		# Create hero entity
		var hero: Hero = Hero.new()
		hero.id = game_state._allocate_entity_id()
		hero.owner_id = pid
		hero.display_name = "Hero %d" % pid
		hero.health = 10
		hero.max_health = 10

		game_state.entities[hero.id] = hero
		game_state.heroes[pid] = hero.id

		# -------------------------
		# Deck / hand
		game_state.decks[pid] = starting_deck_func.call(pid)
		game_state.hands[pid] = []

		# Draw opening hand TODO: mulligan phase
		for i in range(7):
			#var draw_event: DrawCardEvent = DrawCardEvent.new(pid)
			game_state.event_resolver.add_event(DrawCardEvent.new(pid, game_state.tick))

		# -------------------------
		# Mana
		game_state.max_mana[pid] = 1
		game_state.mana[pid] = 1

		# -------------------------
		# Board
		game_state.boards[pid] = []

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
