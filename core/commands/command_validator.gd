extends RefCounted
class_name CommandValidator

var game_state: GameState

func _init(_game_state: GameState) -> void:
	game_state = _game_state
	

func is_valid(command: GameCommand) -> bool:
	if command is AttackCommand:
		return check_attack_command(command)
	elif command is PlayCardCommand:
		return check_play_card_command(command)
	elif command is AdvanceTickCommand:
		return true
	#elif command is HeroPowerCommand:
	#	return check_hero_power_command(command)
	else:
		assert(false, "Unhandled command type: %s" % command)
		return false

func check_attack_command(attack_command: AttackCommand) -> bool:
	var attacker: Entity = game_state.entities.get(attack_command.attacker_id)
	var target: Entity = game_state.entities.get(attack_command.target_id)
	if attacker == null or target == null:
		print("someone is null")
		return false

	if not attacker.has_method("can_attack"):
		print("attacker doesnt have the can_attack method")
		return false

	if not attacker.can_attack(game_state.tick):
		print("%s is too tired to attack! (must wait %d)"
		% [attacker.display_name, attacker.ready_at_tick - game_state.tick])
		return false
	if attacker.owner_id == target.owner_id:
		print ("Can't attack allies!")
		return false
	return true
	
func check_play_card_command(play_card_command: PlayCardCommand) -> bool:
	var card_instance_id = play_card_command.card_instance_id
	var player_id = play_card_command.player_id
	var target_id = play_card_command.target_id #check if target_id is targettable

	if not game_state.hands[player_id].has(card_instance_id):
		print("Card instance %d not in player %d hand"
			% [card_instance_id, player_id])
		return false

	var card_instance: CardInstance = game_state.card_instances.get(card_instance_id)
	if card_instance == null:
		print("Unknown card instance %d" % card_instance_id)
		return false

	var card: CardInfo = card_instance.definition
	if card.cost > game_state.mana[player_id]:
		print("Player %d cannot afford %s"
			% [player_id, card.display_name])
		return false
	return true
