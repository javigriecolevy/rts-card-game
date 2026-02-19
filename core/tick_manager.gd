extends Node
class_name TickManager

@export var tick_rate: float = 1.0
var tick_timer: float = 0.0

var game_state: GameState = GameState.new()
var event_resolver: EventResolver = EventResolver.new(game_state)
var card_db: CardDatabase

var running: bool = false

var command_queue: Array[GameCommand] = []
var command_processor: CommandProcessor = CommandProcessor.new(game_state, game_state.event_resolver)

signal events_emitted(events: Array[GameEvent])

# -------------------------
func _ready() -> void:
	print("TickManager ready (waiting for start)")

	# -------------------------
	# Load card database
	card_db = CardDatabase.new()
	add_child(card_db)

	## -------------------------
	## Print starting hands
	#for pid in game_state.hands.keys():
		#print("Player %d starting hand:" % pid)
		#for card_instance_id in game_state.hands[pid]:
			#var instance: CardInstance = game_state.card_instances[card_instance_id]
			#print(" - %s (cost %d)"
				#% [instance.definition.display_name, instance.definition.cost])
				
# -------------------------
# Initialize game
func initialize_game() -> void:
	game_state = GameState.new()
	event_resolver = EventResolver.new(game_state)
	command_processor = CommandProcessor.new(game_state, game_state.event_resolver)
	
	# -------------------------
	# Setup players
	var deck_func: Callable = Callable(self, "_create_starting_deck")
	game_state.event_resolver.resource_manager.setup_players([1, 2], deck_func)

# -------------------------
func start() -> void:
	initialize_game()
	running = true
	print("TickManager started")

# -------------------------
func _process(delta: float) -> void:
	if not running:
		return

	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		print("\n=== Tick %d ===" % game_state.tick)
		
		
		# tick processing 
		process_commands_for_tick()
		game_state.event_resolver.resolve()
		
		if game_state.emitted_events.size() > 0:
			events_emitted.emit(game_state.emitted_events.duplicate())
			game_state.emitted_events.clear()
			
		game_state.print_current_state()
		#simulate_player_intention()
		
		game_state.tick += 1
		
		if game_state.tick % game_state.cycle_length == 0:
			game_state.event_resolver.resource_manager.refresh_mana()
			game_state.event_resolver.card_manager.draw_for_all_players()


func process_commands_for_tick():
	var remaining: Array[GameCommand] = []
	for cmd in command_queue:
		if cmd.tick != game_state.tick:
			remaining.append(cmd)
			continue
		command_processor.process(cmd)
	
	command_queue = remaining
	
# -------------------------
# Simulate basic player intent
func simulate_player_intention() -> void:
	for pid in game_state.hands.keys():
		if game_state.hands[pid].size() == 0:
			continue

		var card_instance_id: int = game_state.hands[pid][0]
		var target_id: int = _pick_elven_archer_target(pid)

		if target_id == -1:
			continue

		_queue_play_card(pid, card_instance_id, target_id)

	_queue_minion_attacks()

# -------------------------
# Pick target for Elven Archer
func _pick_elven_archer_target(player_id: int) -> int:
	# Prefer enemy minions
	for other_pid in game_state.boards.keys():
		if other_pid == player_id:
			continue

		if game_state.boards[other_pid].size() > 0:
			return game_state.boards[other_pid][0].id

	# Otherwise hit enemy hero
	for other_pid in game_state.heroes.keys():
		if other_pid != player_id:
			return game_state.heroes[other_pid]

	return -1

# -------------------------
# Queue play card command
func _queue_play_card(player_id: int, card_instance_id: int, target_id: int) -> void:
	var cmd: PlayCardCommand = PlayCardCommand.new(
		game_state.tick + 1,
		player_id,
		card_instance_id,
		target_id
	)

	command_queue.append(cmd)

	var instance: CardInstance = game_state.card_instances[card_instance_id]
	print(
		"Queued Player %d to play %s targeting %s"
		% [
			player_id,
			instance.definition.display_name,
			game_state.entities[target_id].display_name
		]
	)

# -------------------------
# Queue minion attacks
func _queue_minion_attacks() -> void:
	for pid in game_state.boards.keys():
		var my_board: Array = game_state.boards[pid]
		if my_board.size() == 0:
			continue

		# Pick enemy player ID
		var enemy_pid: int = -1
		for other_pid in game_state.boards.keys():
			if other_pid != pid:
				enemy_pid = other_pid
				break

		if enemy_pid == -1:
			continue

		for minion in my_board:
			var target_id: int

			if game_state.boards[enemy_pid].size() > 0:
				target_id = game_state.boards[enemy_pid][0].id
			else:
				target_id = game_state.heroes[enemy_pid]

			var cmd: AttackCommand = AttackCommand.new(
				game_state.tick + 1,
				minion.id,
				target_id
			)

			command_queue.append(cmd)

			print(
				"Queued %s(%d) from Player %d to attack %s"
				% [
					minion.display_name,
					minion.id,
					minion.owner_id,
					game_state.entities[target_id].display_name
				]
			)

# -------------------------
# Starting deck
func _create_starting_deck(player_id: int) -> Deck:
	if player_id == 1:
		return Deck.new([
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer"),
			card_db.get_card("elven_archer")
		])
	else:
		return Deck.new([
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer"),
			card_db.get_card("chicken_farmer")
		])
