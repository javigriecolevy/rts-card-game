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
enum SelectionState { IDLE, SELECTING_CARD_TARGET, SELECTING_ATTACK, SELECTING_HERO_POWER_TARGET}
var state: SelectionState = SelectionState.IDLE

var selected_card_id: int = -1
var selected_attacker_id: int = -1

var valid_targets: Array[int] = []

signal valid_targets_modified(valid_targets: Array[int])

# -------------------------
# Setup function
func setup(_tick_manager, _local_player_id, _entity_manager, _hand_manager):
	tick_manager = _tick_manager
	local_player_id = _local_player_id
	entity_manager = _entity_manager
	hand_manager = _hand_manager

	entity_manager.connect("minion_clicked", Callable(self, "_on_minion_clicked"))
	entity_manager.connect("hero_clicked", Callable(self, "_on_hero_clicked"))
	entity_manager.connect("hero_power_clicked", Callable(self, "_on_hero_power_clicked"))
	hand_manager.connect("card_clicked", Callable(self, "_on_card_clicked"))

# -------------------------
# Signal handlers
func _on_card_clicked(card_instance_id: int):
	_reset_card_selection()
	_reset_attack_selection()
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
			_reset_card_selection()
	else:
		state = SelectionState.SELECTING_CARD_TARGET
		_emit_targets()

func _on_minion_clicked(minion_id: int):
	_on_entity_clicked(minion_id)

func _on_hero_clicked(hero_id: int):
	_on_entity_clicked(hero_id)

func _on_hero_power_clicked(hero_id: int):
	if hero_id == local_player_id:
		_reset_card_selection()
		_reset_attack_selection()

		var hero: Hero = tick_manager.game_state.heroes.get(hero_id)
		valid_targets = Targeting.get_valid_targets(
			local_player_id,
			hero.hero_power.target_type,
			hero.hero_power.target_filters,
			tick_manager.game_state
		)
		if valid_targets.is_empty():
			if hero.hero_power.target_optional or hero.hero_power.target_type == Targeting.TargetType.NONE:
				_queue_hero_power(local_player_id)
		else:
			state = SelectionState.SELECTING_HERO_POWER_TARGET
			_emit_targets()

#TODO: make this not stupid
func _on_entity_clicked(entity_id: int):
	match state:
		SelectionState.SELECTING_CARD_TARGET:
			if entity_id in valid_targets:
				_queue_play_card(selected_card_id, entity_id)
			_reset_card_selection()
		
		SelectionState.IDLE:
			var entity: Entity = tick_manager.game_state.entities.get(entity_id)
			if entity.can_attack(tick_manager.game_state.tick) and entity.owner_id == local_player_id:
				_start_attack_selection(entity_id)
		
		SelectionState.SELECTING_ATTACK:
			_finish_attack_selection(entity_id)
		
		SelectionState.SELECTING_HERO_POWER_TARGET:
			if entity_id in valid_targets:
				_queue_hero_power(entity_id)
			_reset_card_selection()
			_reset_attack_selection()

# -------------------------
# Attack selection
func _start_attack_selection(attacker_id: int):
	if selected_attacker_id != -1 or tick_manager.game_state.entities.get(attacker_id) is Hero or not tick_manager.game_state.entities.get(attacker_id).can_attack:
		_reset_card_selection()
		return

	selected_attacker_id = attacker_id
	entity_manager.entity_nodes[selected_attacker_id].is_selected(true)

	state = SelectionState.SELECTING_ATTACK
	valid_targets = Targeting.get_attack_targets(selected_attacker_id, tick_manager.game_state)
	_emit_targets()

func _finish_attack_selection(target_id: int):
	if tick_manager.game_state.entities.get(selected_attacker_id):
		if valid_targets.has(target_id):
			_queue_attack(selected_attacker_id, target_id)
	_reset_attack_selection()

# -------------------------
# Reset helpers
func _reset_attack_selection():
	if selected_attacker_id != -1:
		entity_manager.entity_nodes[selected_attacker_id].is_selected(false)

	selected_attacker_id = -1
	state = SelectionState.IDLE
	_clear_targets()

func _reset_card_selection():
	selected_card_id = -1
	state = SelectionState.IDLE
	_clear_targets()

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
	_clear_targets()

func _queue_attack(attacker_id: int, target_id: int):
	var cmd = AttackCommand.new(
		tick_manager.game_state.tick + tick_manager.INPUT_DELAY,
		local_player_id,
		attacker_id,
		target_id
	)
	tick_manager.send_local_command(cmd)
	_clear_targets()

func _queue_hero_power(target_id: int):
	var cmd = HeroPowerCommand.new(
		tick_manager.game_state.tick + tick_manager.INPUT_DELAY,
		local_player_id,
		target_id
	)
	tick_manager.send_local_command(cmd)
	_clear_targets()

# -------------------------
# Target helpers
func _clear_targets():
	valid_targets.clear()
	_emit_targets()

func _emit_targets():
	emit_signal("valid_targets_modified", valid_targets)

func _get_valid_targets():
	if state == SelectionState.IDLE:
		return
	if state == SelectionState.SELECTING_ATTACK:
		if tick_manager.game_state.entities.has(selected_attacker_id):
			valid_targets = Targeting.get_attack_targets(selected_attacker_id, tick_manager.game_state)
		else:
			valid_targets.clear()
			state = SelectionState.IDLE
			selected_attacker_id = -1
	if state == SelectionState.SELECTING_CARD_TARGET:
		valid_targets = Targeting.get_valid_targets(
		local_player_id,
		tick_manager.game_state.card_instances[selected_card_id].definition.target_type,
		tick_manager.game_state.card_instances[selected_card_id].definition.target_filters,
		tick_manager.game_state
	)
	emit_signal("valid_targets_modified", valid_targets)
