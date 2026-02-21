extends Control
class_name GameView

@export var local_player_id: int = -1
@export var tick_manager: TickManager

var entity_nodes := {}
var card_nodes := {}

var selected_card_id: int = -1
var selected_attacker_id: int = -1

# -------------------------
# Setup
func _ready():
	tick_manager.ui_events_emitted.connect(_on_events_emitted)

# -------------------------
# Initialize perspective
func setup(_local_player_id: int) -> void:
	local_player_id = _local_player_id

# -------------------------
# Initial sync (only once)
func _initialize_full_state():
	var gs = tick_manager.game_state

	# Heroes
	for pid in gs.heroes.keys():
		var hero_id = gs.heroes[pid]
		_create_hero_view(hero_id)

	# Boards
	for pid in gs.boards.keys():
		for minion in gs.boards[pid]:
			_create_minion_view(minion)

	# Hand
	for card_instance_id in gs.hands[local_player_id]:
		_create_card_view(card_instance_id)

# -------------------------
# Event Entry Point
func _on_events_emitted(events: Array[GameEvent]):
	for event in events:
		if event is DrawCardEvent:
			if event.player_id == local_player_id:
				_create_card_view(event.card_instance_id)

		elif event is PlayCardEvent:
			if event.player_id == local_player_id:
				_remove_card_view(event.card_instance_id)

		elif event is SummonEvent:
			_create_minion_view(Minion.new_from_card(card_database.get_card(event.card_db_id), event.player_id, event.tick))

		elif event is DamageEvent:
			_update_entity_health(event.target_id)

		elif event is DeathEvent:
			_remove_entity_view(event.entity_id)

# -------------------------
# Hero UI
func _create_hero_view(hero_id: int):
	var gs = tick_manager.game_state
	var hero = gs.entities[hero_id]

	var scene = preload("res://scenes/ui/hero_view.tscn")
	var view = scene.instantiate()

	view.setup(hero)
	view.hero_clicked.connect(_on_hero_clicked)

	if hero.owner_id == local_player_id:
		$RootLayout/PlayerHeroContainer.add_child(view)
	else:
		$RootLayout/EnemyHeroContainer.add_child(view)

	entity_nodes[hero_id] = view

# -------------------------
# Minion UI
func _create_minion_view(minion):
	var scene = preload("res://scenes/ui/minion_view.tscn")
	var view = scene.instantiate()

	view.setup(minion)
	view.minion_clicked.connect(_on_minion_clicked)

	var container = $RootLayout/PlayerBoard if minion.owner_id == local_player_id else $RootLayout/EnemyBoard

	container.add_child(view)

	entity_nodes[minion.id] = view

func _update_entity_health(entity_id: int):
	if entity_nodes.has(entity_id):
		var entity = tick_manager.game_state.entities.get(entity_id)
		if entity:
			entity_nodes[entity_id].update_stats(entity)

func _remove_entity_view(entity_id: int):
	if entity_nodes.has(entity_id):
		entity_nodes[entity_id].queue_free()
		entity_nodes.erase(entity_id)

# -------------------------
# Hand UI
func _create_card_view(card_instance_id: int):
	var scene = preload("res://scenes/ui/card_view.tscn")
	var view = scene.instantiate()

	var instance = tick_manager.game_state.card_instances[card_instance_id]
	view.setup(card_instance_id, instance.definition)

	view.card_clicked.connect(_on_card_clicked)

	$RootLayout/Hand.add_child(view)
	card_nodes[card_instance_id] = view

func _remove_card_view(card_instance_id: int):
	if card_nodes.has(card_instance_id):
		card_nodes[card_instance_id].queue_free()
		card_nodes.erase(card_instance_id)

# -------------------------
# Input Handling
func _on_card_clicked(card_id: int):
	selected_card_id = card_id
	selected_attacker_id = -1
	_queue_play_card(selected_card_id, -1)

func _on_minion_clicked(minion_id: int):
	# Card targeting
	if selected_card_id != -1:
		_queue_play_card(selected_card_id, minion_id)
		selected_card_id = -1
		return

	# Attack targeting
	if selected_attacker_id != -1:
		_queue_attack(selected_attacker_id, minion_id)
		selected_attacker_id = -1
		return

	# Select attacker
	selected_attacker_id = minion_id

func _on_hero_clicked(hero_id: int):
	if selected_card_id != -1:
		_queue_play_card(selected_card_id, hero_id)
		selected_card_id = -1
	elif selected_attacker_id != -1:
		_queue_attack(selected_attacker_id, hero_id)
		selected_attacker_id = -1

# -------------------------
# Command Queueing
func _queue_play_card(card_id: int, target_id: int):
	var cmd = PlayCardCommand.new(
		tick_manager.game_state.tick + 1,
		local_player_id,
		card_id,
		target_id
	)
	tick_manager.command_queue.append(cmd)

func _queue_attack(attacker_id: int, target_id: int):
	var cmd = AttackCommand.new(
		tick_manager.game_state.tick + 1,
		attacker_id,
		target_id
	)
	tick_manager.command_queue.append(cmd)
