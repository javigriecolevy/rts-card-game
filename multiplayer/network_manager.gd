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

signal remote_command_received(command_data: Dictionary)



func _ready():
	# Optional: helpful logging
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
			print("Lobby full — assigning player slots")

			var all_peers := multiplayer.get_peers()
			all_peers.append(1) # host is always 1
			all_peers.sort()

			for i in all_peers.size():
				peer_to_player_id[all_peers[i]] = i + 1
			print("Peer -> Player mapping:", peer_to_player_id)
			rpc_sync_player_ids.rpc(peer_to_player_id)


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
# Sync Player IDs
# =========================
@rpc("any_peer", "call_local", "reliable")
func rpc_sync_player_ids(mapping: Dictionary):
	peer_to_player_id = mapping

	var my_peer := multiplayer.get_unique_id()
	local_player_id = peer_to_player_id[my_peer]

	print("Assigned game player ID:", local_player_id)

	emit_signal("start_game")

# =========================
# Broadcast Commands
# =========================
@rpc("any_peer", "call_remote", "reliable")
func rpc_broadcast_command(command_data: Dictionary):
	emit_signal("remote_command_received", command_data)
