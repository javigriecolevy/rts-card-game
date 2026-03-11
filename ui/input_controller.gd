extends Node
class_name InputController

# -------------------------
# Dependencies
var local_player_id
var tick_manager: TickManager
var entity_manager: EntityViewManager
var hand_manager: HandViewManager

# -------------------------
# Selection state
enum SelectionState { IDLE, SELECTING_CARD_TARGET, SELECTING_ATTACK }
var state: SelectionState = SelectionState.IDLE

var selected_card_id: int = -1
var selected_attacker_id: int = -1

var valid_targets: Array[int] = []

signal targets_displayed(valid_targets: Array[int])

# -------------------------
# Setup function
func setup(_tick_manager, _local_player_id, _entity_manager, _hand_manager):
	tick_manager = _tick_manager
	local_player_id = _local_player_id
	entity_manager = _entity_manager
	hand_manager = _hand_manager

	entity_manager.connect("minion_clicked", Callable(self, "_on_minion_clicked"))
	entity_manager.connect("hero_clicked", Callable(self, "_on_hero_clicked"))
	hand_manager.connect("card_clicked", Callable(self, "_on_card_clicked"))

# -------------------------
# Signal handlers
func _on_card_clicked(card_instance_id: int):
	selected_card_id = card_instance_id

	var card: CardInstance = tick_manager.game_state.card_instances[card_instance_id]
	valid_targets = Targeting.get_valid_targets(
		local_player_id,
		card.definition.target_type,
		card.definition.target_filters,
		tick_manager.game_state
	)
	
	if valid_targets.is_empty():
		if card.definition.target_optional or card.definition.target_type == Targeting.TargetType.NONE: # Play card with no target 
			_queue_play_card(selected_card_id, -1) # effect should handle skipping when no target
			state = SelectionState.IDLE
	else:
		state = SelectionState.SELECTING_CARD_TARGET
		emit_signal("targets_displayed", valid_targets)

func _on_minion_clicked(minion_id: int):
	match state:
		SelectionState.SELECTING_CARD_TARGET:
			_queue_play_card(selected_card_id, minion_id)
			selected_card_id = -1
			state = SelectionState.IDLE
		
		SelectionState.IDLE:
			if selected_attacker_id == -1:
				selected_attacker_id = minion_id
				entity_manager.entity_nodes[selected_attacker_id].is_selected(true)
				state = SelectionState.SELECTING_ATTACK
				valid_targets = Targeting.get_attack_targets(selected_attacker_id, tick_manager.game_state)
				emit_signal("targets_displayed", valid_targets)
		
		SelectionState.SELECTING_ATTACK:
			if valid_targets.has(minion_id):
				_queue_attack(selected_attacker_id, minion_id)
			entity_manager.entity_nodes[selected_attacker_id].is_selected(false)
			selected_attacker_id = -1
			state = SelectionState.IDLE

func _on_hero_clicked(hero_id: int):
	match state:
		SelectionState.SELECTING_CARD_TARGET:
			_queue_play_card(selected_card_id, hero_id)
			selected_card_id = -1
			state = SelectionState.IDLE
		
		SelectionState.IDLE:
			if selected_attacker_id != -1:
				_queue_attack(selected_attacker_id, hero_id)
				entity_manager.entity_nodes[selected_attacker_id].is_selected(false)
				selected_attacker_id = -1
			
		SelectionState.SELECTING_ATTACK:
			if valid_targets.has(hero_id):
				_queue_attack(selected_attacker_id, hero_id)
			entity_manager.entity_nodes[selected_attacker_id].is_selected(false)
			selected_attacker_id = -1
			state = SelectionState.IDLE

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
	valid_targets.clear()
	emit_signal("targets_displayed", valid_targets)

func _queue_attack(attacker_id: int, target_id: int):
	var cmd = AttackCommand.new(
		tick_manager.game_state.tick + tick_manager.INPUT_DELAY,
		local_player_id,
		attacker_id,
		target_id
	)
	tick_manager.send_local_command(cmd)
	valid_targets.clear()
	emit_signal("targets_displayed", valid_targets)
