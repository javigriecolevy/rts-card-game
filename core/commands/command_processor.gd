extends RefCounted
class_name CommandProcessor

var game_state: GameState
var validator: CommandValidator

func _init(_game_state: GameState, _event_resolver: EventResolver) -> void:
	game_state = _game_state
	validator = CommandValidator.new(game_state)

func process(command: GameCommand) -> void:
	if not validator.is_valid(command):
		return

	if command is PlayCardCommand:
		_process_play_card(command)
	elif command is AttackCommand:
		_process_attack(command)
	else:
		assert(false, "Unhandled command type: %s" % command)

func _process_play_card(cmd: PlayCardCommand) -> void:
	game_state.event_resolver.add_event(
		PlayCardEvent.new(
			cmd.player_id,
			cmd.card_instance_id,
			cmd.target_id,
			game_state.tick
		)
	)

func _process_attack(cmd: AttackCommand) -> void:
	game_state.event_resolver.add_event(
		AttackEvent.new(
			cmd.attacker_id,
			cmd.target_id,
			game_state.tick
		)
	)

#func _process_use_heropower(cmd: UseHeroPowerCommand):
	#pass
