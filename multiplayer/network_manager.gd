extends Node
class_name NetworkManager

signal connected_to_host
signal player_joined(peer_id : int)
signal start_game

const PORT := 12345
const MAX_PLAYERS := 2

var is_host := false
var local_player_id: int = -1
var peer_to_player_id := {}

var decks_info : Dictionary[int, Array] = {} # player id -> array["card_id"] (string)

signal remote_command_received(command_data: Dictionary)
signal remote_deck_received(player_id: int, deck: Array)



func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# ========================
# Hosting / Joining
# ========================

func host_game():
	is_host = true

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error("Failed to host server")
		return

	multiplayer.multiplayer_peer = peer
	print("Hosting game on port", PORT)


func join_game(ip : String):
	is_host = false

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, PORT)
	if err != OK:
		push_error("Failed to join server")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(func ():
		print("Connected to host")
		emit_signal("connected_to_host")
	)


# ========================
# Peer handling
# ========================

func _on_peer_connected(peer_id : int):
	print("Peer connected:", peer_id)
	emit_signal("player_joined", peer_id)

	# Server = host + clients
	if is_host:
		var total_players := multiplayer.get_peers().size() + 1
		print("Players connected:", total_players, "/", MAX_PLAYERS)

		if total_players == MAX_PLAYERS:
			print("Lobby full -- assigning player slots")
			
			var all_peers := multiplayer.get_peers()
			all_peers.append(1) # host is always 1
			all_peers.sort()

			for i in all_peers.size():
				peer_to_player_id[all_peers[i]] = i + 1
			print("Peer -> Player mapping:", peer_to_player_id)
			
			# Host generates deterministic match seed
			var rng := RandomNumberGenerator.new()
			rng.randomize()
			var match_seed := rng.randi()

			print("Generated match seed:", match_seed)
	
			rpc_sync_match_data.rpc(peer_to_player_id, match_seed)


func _on_peer_disconnected(peer_id : int):
	print("Peer disconnected:", peer_id)


# ========================
# Game start sync
# ========================

@rpc("call_local", "reliable")
func rpc_start_game():
	print("Received start game RPC")
	
	# -------------------------
	# Assign player ID based on peer ID
	local_player_id = multiplayer.get_unique_id()
	print("Assigned local player ID:", local_player_id)

	emit_signal("start_game")

# =========================
# Sync Player IDs and RNG seed
# =========================
@rpc("any_peer", "call_local", "reliable")
func rpc_sync_match_data(mapping: Dictionary, match_seed: int):
	peer_to_player_id = mapping
	
	var my_peer := multiplayer.get_unique_id()
	local_player_id = peer_to_player_id[my_peer]
	#decks_info[local_player_id] = load_deck("res://selected_deck/deck.txt")
	print("Assigned game player ID:", local_player_id)
	print("Received match seed:", match_seed)
	
	var deck: Array[String] = load_deck("res://selected_deck/deck.txt")
	decks_info[local_player_id] = deck
	rpc_send_deck.rpc(local_player_id, deck)
	
	emit_signal("start_game", match_seed, decks_info)

# =========================
# Broadcast Commands
# =========================
@rpc("any_peer", "call_remote", "reliable")
func rpc_broadcast_command(command_data: Dictionary):
	emit_signal("remote_command_received", command_data)

@rpc("any_peer", "call_remote", "reliable")
func rpc_send_deck(player_id: int, deck: Array):
	print("AAA", local_player_id, "Received deck from player: ", player_id)
	decks_info[player_id] = deck
	emit_signal("remote_deck_received", player_id, deck)

func load_deck(path: String) -> Array[String]:
	var cards: Array[String] = []
	var file := FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line != "" and not line.begins_with("#"):
			cards.append(line)
	return cards
