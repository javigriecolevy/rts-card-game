extends Node
class_name HandViewManager

var tick_manager
var local_player_id
var hand_container
var card_nodes: Dictionary[int, Node] = {}

signal card_clicked(card_instance_id: int)

func setup(_tick_manager, _local_player_id, _hand_container):
	tick_manager = _tick_manager
	local_player_id = _local_player_id
	hand_container = _hand_container

func create_card(card_instance_id: int):
	var scene = preload("res://scenes/ui/hand_card_view.tscn")
	var view = scene.instantiate()
	var instance = tick_manager.game_state.card_instances[card_instance_id]
	view.setup(card_instance_id, instance.definition)
	view.card_clicked.connect(self._on_card_clicked)
	hand_container.add_child(view)
	card_nodes[card_instance_id] = view

func remove_card(card_instance_id: int):
	if card_nodes.has(card_instance_id):
		card_nodes[card_instance_id].queue_free()
		card_nodes.erase(card_instance_id)

func _on_card_clicked(card_instance_id: int):
	emit_signal("card_clicked", card_instance_id)
