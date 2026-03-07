extends Node
class_name InputController

# -------------------------
# Dependencies
var tick_manager
var local_player_id
var entity_manager
var hand_manager

# -------------------------
# Selection state
enum SelectionState { IDLE, SELECTING_CARD_TARGET, SELECTING_ATTACK }
var state: SelectionState = SelectionState.IDLE

var selected_card_id: int = -1
var selected_attacker_id: int = -1

# -------------------------
# Setup function
func setup(_tick_manager, _local_player_id, _entity_manager, _hand_manager):
	tick_manager = _tick_manager
	local_player_id = _local_player_id
	entity_manager = _entity_manager
	hand_manager = _hand_manager

	# Connect signals from managers to this controller
	entity_manager.connect("minion_clicked", Callable(self, "_on_minion_clicked"))
	entity_manager.connect("hero_clicked", Callable(self, "_on_hero_clicked"))
	hand_manager.connect("card_clicked", Callable(self, "_on_card_clicked"))

# -------------------------
# Signal handlers
func _on_card_clicked(card_instance_id: int):
	selected_card_id = card_instance_id
	var card_def = tick_manager.game_state.card_instances[card_instance_id].definition

	if card_def.requires_target:
		state = SelectionState.SELECTING_CARD_TARGET
	else:
		_queue_play_card(selected_card_id, -1)
		selected_card_id = -1
		state = SelectionState.IDLE

func _on_minion_clicked(minion_id: int):
	match state:
		SelectionState.SELECTING_CARD_TARGET:
			_queue_play_card(selected_card_id, minion_id)
			selected_card_id = -1
			state = SelectionState.IDLE
		SelectionState.IDLE:
			if selected_attacker_id == -1:
				selected_attacker_id = minion_id
			else:
				_queue_attack(selected_attacker_id, minion_id)
				selected_attacker_id = -1

func _on_hero_clicked(hero_id: int):
	match state:
		SelectionState.SELECTING_CARD_TARGET:
			_queue_play_card(selected_card_id, hero_id)
			selected_card_id = -1
			state = SelectionState.IDLE
		SelectionState.IDLE:
			if selected_attacker_id != -1:
				_queue_attack(selected_attacker_id, hero_id)
				selected_attacker_id = -1

# -------------------------
# Queue commands
func _queue_play_card(card_id: int, target_id: int):
	var cmd = PlayCardCommand.new(
		tick_manager.game_state.tick + tick_manager.INPUT_DELAY,
		local_player_id,
		card_id,
		target_id
	)
	tick_manager.send_local_command(cmd)

func _queue_attack(attacker_id: int, target_id: int):
	var cmd = AttackCommand.new(
		tick_manager.game_state.tick + tick_manager.INPUT_DELAY,
		local_player_id,
		attacker_id,
		target_id
	)
	tick_manager.send_local_command(cmd)
