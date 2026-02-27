extends Node
class_name TickManager

@export var tick_rate: float = 0.001

@onready var network := get_node("/root/GameRoot/NetworkManager")

const INPUT_DELAY: int = 2

var tick_timer: float = 0.0

var game_state: GameState = GameState.new()
var event_resolver: EventResolver = EventResolver.new(game_state)

var running: bool = false
var local_player_id: int = -1

var commands_by_tick: Dictionary = {} # tick -> Array[GameCommand]
var command_processor: CommandProcessor = CommandProcessor.new(game_state, game_state.event_resolver)

signal ui_events_ready(events: Array[GameEvent])

# -------------------------
func _ready() -> void:
	print("TickManager ready (waiting for start)")

# -------------------------
# Initialize game
func initialize_game() -> void:
	# -------------------------
	# Setup players
	var deck_func: Callable = Callable(self, "_create_starting_deck")
	game_state.event_resolver.resource_manager.setup_players([1, 2], deck_func)
	send_local_command(AdvanceTickCommand.new(game_state.tick, local_player_id))

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
	# Update ui if there are any pending ui events
	if game_state.ui_event_queue.size() > 0:
		ui_events_ready.emit(game_state.ui_event_queue)
		game_state.ui_event_queue.clear()
	
	# -------------------------
	# Check if game is running, timer is above tick rate and all players have advanced tick
	if _can_advance_tick(delta):
		# We safely advance to next tick
		
		# Tick processing
		process_commands_for_tick()
		game_state.event_resolver.resolve()
		
		# -------------------------
		# Check if current tick is new cycle
		if game_state.tick % game_state.cycle_length == 0:
			game_state.event_resolver.resource_manager.refresh_mana()
			game_state.event_resolver.card_manager.draw_for_all_players()
		# -------------------------
		game_state.tick += 1
		tick_timer = 0.0
		# We announce that we've advanced this tick
		send_local_command(AdvanceTickCommand.new(game_state.tick, local_player_id))
		
		#DEBUG OUTPUT. TODO: REMOVE
		print("\n=== Tick %d from Player %d ===" % [game_state.tick - 1, local_player_id])
		game_state.print_current_state()

# -------------------------
# Command handling
func send_local_command(cmd: GameCommand):
	# Schedule locally
	queue_command(cmd)
	# Send to others
	network.rpc_broadcast_command.rpc(cmd.serialize())

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
		return a.player_id - b.player_id
	)
	for cmd in cmds:
		command_processor.process(cmd)
	commands_by_tick.erase(game_state.tick)

# -------------------------
func _can_advance_tick(delta: float) -> bool:
	# Check if timer is above tick rate
	if tick_timer < tick_rate:
		tick_timer += delta
		return false
	# Check if paused and recieved advance tick from all players
	if not running or not _advance_tick_command_recieved():
		return false
	
	return true

# -------------------------
# Checks if all players have sent the advance tick command
func _advance_tick_command_recieved():
	if not commands_by_tick.has(game_state.tick):
		return false

	var current_tick_commands: Array = commands_by_tick[game_state.tick]
	var players_with_empty := {}

	for command: GameCommand in current_tick_commands:
		if command is AdvanceTickCommand:
			players_with_empty[command.player_id] = true

	for pid in game_state.heroes.keys():
		if not players_with_empty.has(pid):
			return false
	
	return true
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
