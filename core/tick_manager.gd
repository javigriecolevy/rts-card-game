extends Node
class_name TickManager

@export var tick_rate: float = 1.0
var tick_timer: float = 0.0

var game_state: GameState = GameState.new()
var event_resolver: EventResolver = EventResolver.new(game_state)

var running: bool = false
var local_player_id: int = -1

var command_queue: Array[GameCommand] = []
var command_processor: CommandProcessor = CommandProcessor.new(game_state, game_state.event_resolver)

signal events_emitted(events: Array[Dictionary])
signal ui_events_emitted(events: Array[GameEvent])

# -------------------------
func _ready() -> void:
	print("TickManager ready (waiting for start)")

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
func start_host():
	running = true
	initialize_game()
	
	print("TickManager started as host")

func start_client():
	running = false
	initialize_game()
	
	print("TickManager started as client")

# -------------------------
func _process(delta: float) -> void:
	if delta == 0 && running: 	 # Draw opening hand TODO: mulligan phase
		for pid in game_state.heroes:
			for i in range(7):
				game_state.event_resolver.add_event(DrawCardEvent.new(pid, 1))
				game_state.emit(DrawCardEvent.new(pid, 1))
	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		print("\n=== Tick %d from Player %d ===" % [game_state.tick, local_player_id])
		
		# tick processing
		 
		process_commands_for_tick()

		game_state.event_resolver.resolve()
		
		_emit_events()
		ui_events_emitted.emit(game_state.UI_emitted_events)
		game_state.UI_emitted_events.clear()
		
		
		if game_state.tick % game_state.cycle_length == 0 && running:
			game_state.event_resolver.resource_manager.refresh_mana()
			game_state.event_resolver.card_manager.draw_for_all_players()
		
		game_state.tick += 1
		
		game_state.print_current_state()
		#simulate_player_intention()

func process_commands_for_tick():
	var remaining: Array[GameCommand] = []
	for cmd in command_queue:
		if cmd.tick != game_state.tick:
			remaining.append(cmd)
			continue
		command_processor.process(cmd)
	
	command_queue = remaining
	
func apply_remote_events(net_events: Array) -> void:
	print("Applying remote events: ", net_events.size())
	for event_data in net_events:
		var event: GameEvent = load(event_data["type"]).new()
		event.deserialize(event_data)
		game_state.event_resolver.add_event(event)
	game_state.event_resolver.resolve()
	#ui_events_emitted.emit(game_state.UI_emitted_events)
	#game_state.UI_emitted_events.clear()
	#print("Client GameState: ")
	print("\n=== Tick %d from Player %d ===" % [game_state.tick, local_player_id])
	game_state.print_current_state()

func _emit_events():
	if game_state.serialized_emitted_events.size() > 0:
		print("emitting local events: ", game_state.serialized_emitted_events.size())
		events_emitted.emit(game_state.serialized_emitted_events.duplicate())
		game_state.serialized_emitted_events.clear()

# -------------------------
# Starting deck
func _create_starting_deck(player_id: int) -> Deck:
	if player_id == 1:
		return Deck.new([
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer"),
			card_database.get_card("elven_archer")
		])
	else:
		return Deck.new([
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer"),
			card_database.get_card("chicken_farmer")
		])
