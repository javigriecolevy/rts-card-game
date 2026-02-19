extends Node2D

@onready var network := $NetworkManager
@onready var tick_manager := $TickManager
@onready var game_view := $GameView

func _ready():
	print("Main ready")

	# When the network says "start", begin ticking
	network.start_game.connect(_on_start_game)

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
	tick_manager.start()
	game_view.setup(network.local_player_id)
	game_view._initialize_full_state()
