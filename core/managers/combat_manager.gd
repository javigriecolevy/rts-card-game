extends RefCounted
class_name CombatManager

var game_state: GameState

# -------------------------
# Listeners for event-driven effects - Dictionary<Script, Array<Effect>>
var listeners: Dictionary = {} # GameEvent -> Array[Effect]

func _init(_game_state: GameState) -> void:
	game_state = _game_state

# -------------------------
# Combat
func handle_attack(event: AttackEvent) -> void:
	var attacker: Entity = game_state.entities.get(event.attacker_id)
	var target: Entity = game_state.entities.get(event.target_id)
	# -------------------------
	# Consume attack
	attacker.on_attack(game_state.tick)
	
	print("%s attacks %s"
		% [attacker.display_name, target.display_name])
	
	# Queue damage events instead of applying damage directly
	var dmg_to_target: DamageEvent = DamageEvent.new(attacker.id, target.id, attacker.attack, event.tick)
	game_state.event_resolver.add_event(dmg_to_target)
	
	if target is Minion and target.attack > 0:
		var dmg_to_attacker: DamageEvent = DamageEvent.new(target.id, attacker.id, target.attack, event.tick)
		game_state.event_resolver.add_event(dmg_to_attacker)

# -------------------------
# Handle a damage event
func handle_damage(event: DamageEvent) -> void:
	var target: Entity = game_state.entities.get(event.target_id)
	if target == null:
		print("Damage skipped: target %d not found" % event.target_id)
		return
	
	target.health -= event.amount
	print("%s takes %d damage (%d remaining)"
		% [target.display_name, event.amount, target.health])
	
	if target.health <= 0:
		var death_event: DeathEvent = DeathEvent.new(target.id, event.tick)
		game_state.event_resolver.add_event(death_event)

# -------------------------
# Handle minion summon
func handle_summon(event: SummonEvent):
	var player_id = event.player_id
	var minion: Minion = Minion.new_from_card(card_database.get_card(event.card_db_id), player_id, event.tick)
	minion.id = game_state._allocate_entity_id()
	
	game_state.entities[minion.id] = minion
	game_state.boards[player_id].append(minion)
	
	# Trigger battlecry
	if event.from_play:
		for effect in minion.card.effects:
			if effect.trigger == effect.Trigger.BATTLECRY:
				effect.source_player_id = player_id
				effect.source_entity_id = minion.id
				effect.apply_effect(game_state, event.battlecry_target_id)

	# Check for event trigger and add to listener list
	for effect: Effect in minion.card.effects:
		if effect.trigger_event_class:
			effect.source_player_id = minion.owner_id
			_register_listener(effect.trigger_event_class, effect)

# -------------------------
# Handle a death event
func handle_death(event: DeathEvent) -> void:
	var entity: Entity = game_state.entities.get(event.entity_id)
	if entity == null:
		print("Entity %d not found for death resolution." % event.entity_id)
		return
	
	# Log entity death
	print("%s has died" % entity.display_name)
			
	# Remove entity from all game structures
	game_state.remove_entity(entity)
	
	# Apply deathrattle
	if entity is Minion:
		for effect in entity.card.effects:
			# Check for deathrattle
			if effect.trigger == effect.Trigger.DEATHRATTLE:
				effect.source_entity_id = entity.id
				effect.source_player_id = entity.owner_id
				effect.apply_effect(game_state, -1)
			# Check for event trigger and remove from listener list
			if effect.trigger_event_class:
				_unregister_listener(effect.trigger_event_class, effect)
	
	if entity is Hero:
		print("Hero %s has died. Game Over!" % entity.display_name)
		# TODO: end the game !

# -------------------------
# Register an effect as listener for a specific GameEvent Script
func _register_listener(event_script: Script, effect: Effect) -> void:
	if not listeners.has(event_script):
		listeners[event_script] = []
	listeners[event_script].append(effect)

# Unregister
func _unregister_listener(event_script: Script, effect: Effect) -> void:
	if listeners.has(event_script):
		listeners[event_script].erase(effect)
		if listeners[event_script].is_empty():
			listeners.erase(event_script)

# -------------------------
# Trigger event-driven effects
func process_triggers(event: GameEvent) -> void:
	var event_script: Script = event.get_script()
	if not listeners.has(event_script):
		return
	# Sort listeners deterministically
	listeners[event_script].sort_custom(self._compare_effects)
	
	for effect: Effect in listeners[event_script]:
		# Apply effect
		effect.apply_effect(game_state, -1)

func _compare_effects(a: Effect, b: Effect) -> int:
	# 1. By player ID
	if a.source_player_id != b.source_player_id:
		return a.source_player_id - b.source_player_id
	# 2. By source entity ID
	return a.source_entity_id - b.source_entity_id
