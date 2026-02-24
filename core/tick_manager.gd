extends Node
class_name TickManager

@export var tick_rate: float = 2.0

@onready var network := get_node("/root/GameRoot/NetworkManager")

const INPUT_DELAY: int = 1

var tick_timer: float = 0.0

var game_state: GameState = GameState.new()
var event_resolver: EventResolver = EventResolver.new(game_state)

var running: bool = false
var local_player_id: int = -1

var commands_by_tick: Dictionary = {} # tick -> Array[GameCommand]
var command_processor: CommandProcessor = CommandProcessor.new(game_state, game_state.event_resolver)

signal ui_events_emitted(events: Array[GameEvent])

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
	tick_timer += delta
	
	ui_events_emitted.emit(game_state.UI_emitted_events)
	game_state.UI_emitted_events.clear()
	
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		print("\n=== Tick %d from Player %d ===" % [game_state.tick, local_player_id])
		
		# tick processing
		process_commands_for_tick()
		game_state.event_resolver.resolve()
		
		if game_state.tick % game_state.cycle_length == 0:
			game_state.event_resolver.resource_manager.refresh_mana()
			game_state.event_resolver.card_manager.draw_for_all_players()
		
		game_state.tick += 1
		
		game_state.print_current_state()
# -------------------------

func send_local_command(cmd: GameCommand):
	# Schedule locally
	queue_command(cmd)
	# Send to others
	network.rpc_broadcast_command.rpc(cmd.serialize())

func _on_remote_command_received(data: Dictionary):
	var script: Script = load(data["type"])
	var cmd: GameCommand = script.new(0)
	cmd.deserialize(data)

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
		
		#for pid in game_state.heroes:
			#for i in range(7):
				#game_state.event_resolver.add_event(DrawCardEvent.new(pid, 1))
				#game_state.emit(DrawCardEvent.new(pid, 1))
