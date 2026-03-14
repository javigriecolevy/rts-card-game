extends Control
class_name GameView

@export var tick_manager: TickManager
@export var PlayerBoard: HBoxContainer
@export var EnemyBoard: HBoxContainer
@export var EnemyHeroContainer: HBoxContainer
@export var PlayerHeroContainer: HBoxContainer
@export var Hand: HBoxContainer
@export var PlayerHeroPowerContainer: HBoxContainer
@export var EnemyHeroPowerContainer: HBoxContainer
@export var PlayerMana: Label
@export var EnemyMana: Label
@export var CycleTimer: CircularTimer

var local_player_id: int = -1
var enemy_player_id

var entity_manager: EntityViewManager
var game_state: GameState
var hand_manager: HandViewManager
var input_controller: InputController


func setup():
	# Initialize managers
	entity_manager = EntityViewManager.new()
	hand_manager = HandViewManager.new()
	input_controller = InputController.new()
	game_state = tick_manager.game_state
	
	entity_manager.setup(tick_manager, local_player_id, $PlayerBoard, $EnemyBoard, $PlayerHeroContainer, $EnemyHeroContainer)
	hand_manager.setup(tick_manager, local_player_id, $Hand)
	input_controller.setup(tick_manager, local_player_id, entity_manager, hand_manager)
	
	# Connect events
	tick_manager.ui_events_resolved.connect(_on_events_emitted)
	tick_manager.tick_advanced.connect(_on_tick_advanced)
	tick_manager.game_state.enchantment_manager.entity_recalculated.connect(entity_manager.update_entity_stats)
	input_controller.valid_targets_modified.connect(_on_displayed_targets)
	
	for pid in game_state.heroes.keys():
		var hero_id = game_state.heroes[pid].id
		entity_manager.create_hero(hero_id)
		
	if local_player_id == 1:
		enemy_player_id = 2
	else:
		enemy_player_id = 1
	
func _on_events_emitted(events: Array):
	for event in events:
		if event is DrawCardEvent:
			if event.player_id == local_player_id:
				hand_manager.create_card(event.card_instance_id)

		elif event is PlayCardEvent:
			if event.player_id == local_player_id:
				hand_manager.remove_card(event.card_instance_id)

		elif event is SummonEvent:
			entity_manager.update_board(event.player_id)
			input_controller._get_valid_targets()

		elif event is DamageEvent:
			entity_manager.update_entity_stats(event.target_id)

		elif event is DeathEvent:
			entity_manager.remove_entity(event.entity_id)
			input_controller._get_valid_targets()

		else:
			print("Unhandled event type: ", event)
			entity_manager.update_entity_stats(event.target_id)
		hand_manager.update_afford_glow()
		PlayerMana.text = str("MANA: %d/%d" % [game_state.mana[local_player_id], game_state.max_mana[local_player_id]])
		EnemyMana.text = str("MANA: %d/%d" % [game_state.mana[enemy_player_id], game_state.max_mana[local_player_id]])
		

# Draw a card into the player's hand
func _handle_draw_card(event: DrawCardEvent):
	if event.player_id == local_player_id:
		hand_manager.create_card(event.card_instance_id)

# Remove a card from hand after play
func _handle_play_card(event: PlayCardEvent):
	if event.player_id == local_player_id:
		hand_manager.remove_card(event.card_instance_id)

# Summon a minion to the board
func _handle_summon(event: SummonEvent):
	var board = tick_manager.game_state.boards[event.player_id]
	for minion: Minion in board:
		entity_manager.remove_entity(minion.id) # ensure no duplicates
		entity_manager.create_minion(minion)

# Apply damage to an entity
func _handle_damage(event: DamageEvent):
	entity_manager._update_entity_stats(event.target_id)

# Remove dead entity from board
func _handle_death(event: DeathEvent):
	entity_manager.remove_entity(event.entity_id)

func _on_tick_advanced(current_tick: int):
	entity_manager.update_attack_glow(current_tick)
	entity_manager.update_timers(current_tick)
	_update_cycle_timer(current_tick)

func _on_displayed_targets(target_ids: Array[int]):
	entity_manager.update_target_glow(target_ids)

func _update_cycle_timer(tick: int):
	var progress =  float(tick % game_state.cycle_length) / (game_state.cycle_length - 1)
	CycleTimer.set_progress(progress)
