extends Node
class_name EntityViewManager

# -------------------------
# Dependencies
var tick_manager
var local_player_id

var player_board: Node
var enemy_board: Node
var player_hero_container: Node
var enemy_hero_container: Node

# Store entity nodes by ID
var entity_nodes: Dictionary[int, Node] = {}

# -------------------------
# Signals
signal minion_clicked(minion_id: int)
signal hero_clicked(hero_id: int)

# -------------------------
# Setup
func setup(_tick_manager, _local_player_id, _player_board, _enemy_board, _player_hero_container, _enemy_hero_container):
	tick_manager = _tick_manager
	local_player_id = _local_player_id
	player_board = _player_board
	enemy_board = _enemy_board
	player_hero_container = _player_hero_container
	enemy_hero_container = _enemy_hero_container

# -------------------------
# Hero functions
func create_hero(hero_id: int):
	var gs = tick_manager.game_state
	var hero = gs.entities[hero_id]

	var scene = preload("res://scenes/ui/hero_view.tscn")
	var view = scene.instantiate()
	view.setup(hero)

	# Connect internal click to forward signal
	view.hero_clicked.connect(_on_hero_clicked)

	if hero.owner_id == local_player_id:
		player_hero_container.add_child(view)
	else:
		enemy_hero_container.add_child(view)

	entity_nodes[hero_id] = view

# -------------------------
# Minion functions
func create_minion(minion):
	var container = player_board if minion.owner_id == local_player_id else enemy_board
	var scene = preload("res://scenes/ui/minion_view.tscn")
	var view = scene.instantiate()
	view.setup(minion)

	# Connect internal click to forward signal
	view.minion_clicked.connect(_on_minion_clicked)

	container.add_child(view)
	entity_nodes[minion.id] = view

# -------------------------
# Remove entity
func remove_entity(entity_id: int):
	if entity_nodes.has(entity_id):
		entity_nodes[entity_id].queue_free()
		entity_nodes.erase(entity_id)

# -------------------------
# Update entity stats
func update_entity_stats(entity_id: int):
	if entity_nodes.has(entity_id):
		var entity = tick_manager.game_state.entities.get(entity_id)
		if entity:
			entity_nodes[entity_id].update_stats(entity)

# Public method
func update_board(player_id: int):
	# Get all minions on the board for this player
	for minion in tick_manager.game_state.boards[player_id]:
		# Remove old view if it exists
		if entity_nodes.has(minion.id):
			remove_entity(minion.id)
		
		# Create new view
		create_minion(minion)

# -------------------------
# Signal forwarding
func _on_minion_clicked(minion_id: int):
	emit_signal("minion_clicked", minion_id)

func _on_hero_clicked(hero_id: int):
	emit_signal("hero_clicked", hero_id)
