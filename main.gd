extends Node2D

@onready var network: NetworkManager = $NetworkManager
@onready var tick_manager: TickManager = $TickManager
@onready var game_view : GameView = $GameView

func _ready():
	print("Main ready")

	# When the network says "start", begin ticking
	network.start_game.connect(_on_start_game)
	network.remote_command_received.connect(_on_remote_command)
	network.remote_deck_received.connect(_on_remote_deck)
	# TEMP: hardcoded for now
	# Run one instance as host, one as client
	if OS.has_feature("server"):
		print("Running as host")
		network.host_game()
	else:
		print("Running as client")
		network.join_game("127.0.0.1")

func _on_start_game(match_seed: int, decks: Dictionary):
	print("Main received start_game")
	tick_manager.match_seed = match_seed
	tick_manager.local_player_id = network.local_player_id
	
	tick_manager.starting_decks = network.decks_info

func _on_remote_command(data: Dictionary):
	var script: Script = load(data["type"])
	var cmd: GameCommand = script.new()
	cmd.deserialize(data)
	tick_manager.queue_command(cmd)

#TODO: make this not stupid
func _on_remote_deck(player_id: int, deck: Array[String]):
	print("remote deck received from", player_id)
	tick_manager.starting_decks[player_id] = deck
	if (tick_manager.starting_decks.size() == network.MAX_PLAYERS):
		if network.is_host:
			tick_manager.start_host()
		else:
			tick_manager.start_client()
		game_view.local_player_id = network.local_player_id
		game_view.setup()

func load_deck(path: String) -> Array[String]:
	var cards: Array[String] = []
	var file := FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line != "" and not line.begins_with("#"):
			cards.append(line)
	return cards
	
func _all_decks_received() -> bool:
	return true
