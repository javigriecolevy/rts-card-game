class_name Lobby
extends Node

signal lobby_ready(player_ids : Array)

var players : Array = []
var max_players := 2

func add_player(peer_id : int):
	if players.has(peer_id):
		return

	players.append(peer_id)
	print("Player joined lobby:", peer_id)

	if players.size() == max_players:
		emit_signal("lobby_ready", players)
