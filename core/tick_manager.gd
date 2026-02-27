extends Node
class_name TickManager

@export var tick_rate: float = 0.001

@onready var network := get_node("/root/GameRoot/NetworkManager")

const INPUT_DELAY: int = 2

var tick_timer: float = 0.0

var game_state: GameState = GameState.new()

var running: bool = false
var local_player_id: int = -1
var finalized_local_tick: int = -1
var match_seed: int = -1

var commands_by_tick: Dictionary = {} # tick -> Array[GameCommand]
var command_processor: CommandProcessor = CommandProcessor.new(game_state, game_state.event_resolver)

signal ui_events_resolved(events: Array[GameEvent])

# -------------------------
func _ready() -> void:
	print("TickManager ready (waiting for start)")

# -------------------------
# Initialize game
func initialize_game() -> void:
	# Setup seeded rng
	game_state.rng = RandomNumberGenerator.new()
	game_state.rng.seed = match_seed
	
	# Setup players
	var deck_func: Callable = Callable(self, "_create_starting_deck")
	game_state.event_resolver.resource_manager.setup_players([1, 2], deck_func)
	
	print("Current match_seed for Player %d is: %d" % [local_player_id, match_seed])

# -------------------------
func start_host():
	initialize_game()
	running = true
	print("TickManager started as host")

func start_client():
	initialize_game()
	running = true
	print("TickManager started as client")

# -------------------------
func _process(delta: float) -> void:
	if not running:
		return

	_dispatch_ui_events()
	_update_tick_timer(delta)
	_try_advance_tick()

# -------------------------
# Update ui if there are any pending ui events
func _dispatch_ui_events():
	if not game_state.ui_event_queue.is_empty():
		ui_events_resolved.emit(game_state.ui_event_queue)
		game_state.ui_event_queue.clear()

# -------------------------
# Advances tick timer and sends EndInput at the end of tick
func  _update_tick_timer(delta: float):
	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		# Finalize input for this tick when input window closes
		if finalized_local_tick != game_state.tick:
			send_local_command(EndInputCommand.new(game_state.tick, local_player_id))
			finalized_local_tick = game_state.tick

# -------------------------
# After recieving all EndInputCommands handles current tick processing and advances
func _try_advance_tick() -> void:
	if _all_players_ended_input():
		# Solves current tick
		process_commands_for_tick()
		game_state.event_resolver.resolve()
		_handle_cycle()
	
		game_state.tick += 1 # Advances to next tick
		
		#DEBUG OUTPUT. TODO: REMOVE
		print("\n=== Tick %d from Player %d ===" % [game_state.tick - 1, local_player_id])
		game_state.print_current_state()

# -------------------------
# Checks if recieved end input command from all players
func _all_players_ended_input() -> bool:
	if not commands_by_tick.has(game_state.tick):
		return false
	
	var ended_count: int = 0
	var total_players: int = game_state.heroes.size()
	
	for cmd in commands_by_tick[game_state.tick]:
		if cmd is EndInputCommand:
			ended_count += 1
	
	return ended_count == total_players

# -------------------------
# Refreshes mana and draws cards at the start of each new cycle
func _handle_cycle():
		if game_state.tick % game_state.cycle_length == 0:
			game_state.event_resolver.resource_manager.refresh_mana()
			game_state.event_resolver.card_manager.draw_for_all_players()

# -------------------------
# Command handling
# -------------------------
func send_local_command(cmd: GameCommand):
	queue_command(cmd) # Schedule locally
	network.rpc_broadcast_command.rpc(cmd.serialize()) # Send to others

func _on_remote_command_received(data: Dictionary):
	var script: Script = load(data["type"])
	var cmd: GameCommand = script.new()
	cmd.deserialize(data)
	queue_command(cmd)

func queue_command(cmd: GameCommand):
	if not commands_by_tick.has(cmd.tick):
		commands_by_tick[cmd.tick] = []
	commands_by_tick[cmd.tick].append(cmd)

func process_commands_for_tick():
	if not commands_by_tick.has(game_state.tick):
		return
	
	var cmds: Array = commands_by_tick[game_state.tick]
	# Sort deterministically
	cmds.sort_custom(func(a, b):
		return a.player_id < b.player_id
	)
	for cmd in cmds:
		command_processor.process(cmd)
	commands_by_tick.erase(game_state.tick)
# -------------------------

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
