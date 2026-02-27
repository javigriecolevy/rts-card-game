extends Node2D

@onready var network := $NetworkManager
@onready var tick_manager := $TickManager
@onready var game_view := $GameView

func _ready():
	print("Main ready")

	# When the network says "start", begin ticking
	network.start_game.connect(_on_start_game)
	network.remote_command_received.connect(_on_remote_command)
	# TEMP: hardcoded for now
	# Run one instance as host, one as client
	if OS.has_feature("server"):
		print("Running as host")
		network.host_game()
	else:
		print("Running as client")
		network.join_game("127.0.0.1")

func _on_start_game(match_seed: int):
	print("Main received start_game")
	tick_manager.match_seed = match_seed
	tick_manager.local_player_id = network.local_player_id
	#tick_manager.initialize_game()
	tick_manager.local_player_id = network.local_player_id
	if network.is_host:
		tick_manager.start_host()
	else:
		tick_manager.start_client()
	game_view.setup(network.local_player_id)
	game_view._initialize_full_state()
	
func _on_remote_command(data: Dictionary):
	var script: Script = load(data["type"])
	var cmd: GameCommand = script.new()
	cmd.deserialize(data)
	tick_manager.queue_command(cmd)
