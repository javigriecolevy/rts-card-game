extends Node2D

@onready var network := $NetworkManager
@onready var tick_manager := $TickManager
@onready var game_view := $GameView

func _ready():
	print("Main ready")

	# When the network says "start", begin ticking
	network.start_game.connect(_on_start_game)
	network.remote_events_received.connect(_on_remote_events_received)
	tick_manager.events_emitted.connect(_on_events_emitted)
	
	# TEMP: hardcoded for now
	# Run one instance as host, one as client
	if OS.has_feature("server"):
		print("Running as host")
		network.host_game()
	else:
		print("Running as client")
		network.join_game("127.0.0.1")

func _on_start_game():
	print("Main received start_game")
	
	#tick_manager.initialize_game()
	
	if network.is_host:
		tick_manager.start_host()
	else:
		tick_manager.start_client()
	game_view.setup(network.local_player_id)
	tick_manager.local_player_id = network.local_player_id
	game_view._initialize_full_state()

func _on_remote_events_received(events: Array):
	if network.is_host:
		print(">>> HOST received", events.size(), "events")
	else:
		print(">>> CLIENT received", events.size(), "events")

	tick_manager.apply_remote_events(events)

func _on_events_emitted(events: Array):
	if network.is_host:
		print(">>> HOST broadcasting", events.size(), "events")
	else:
		print(">>> CLIENT broadcasting", events.size(), "events")
	network.rpc_broadcast_events.rpc(events)
