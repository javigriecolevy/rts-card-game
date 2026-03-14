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
	
	if target.attack > 0:
		var dmg_to_attacker: DamageEvent = DamageEvent.new(target.id, attacker.id, target.attack, event.tick)
		game_state.event_resolver.add_event(dmg_to_attacker)

# -------------------------
# Handle a damage event
func handle_damage(event: DamageEvent) -> void:
	var target: Entity = game_state.entities.get(event.target_id)
	var source: Entity = game_state.entities.get(event.source_id)
	if target == null or source == null:
		print("Damage skipped: target %d not found" % event.target_id)
		return
	
	var damage = event.amount
	
	for enchantment: Enchantment in target.enchantments:
		if enchantment is ActiveEnchantment:
			damage = enchantment.on_damage_taken(target.id, game_state, damage)
	
	if damage > 0:
		for enchantment: Enchantment in source.enchantments:
			if enchantment is ActiveEnchantment:
				enchantment.on_damage_dealt(source.id, game_state, target.id)
	
	if target is Hero && target.armor > 0:
		target.armor -= damage
		if target.armor < 0:
			target.health += target.armor
			target.armor = 0
	else:
		target.health -= damage
	
	if target.health <= 0:
		var death_event: DeathEvent = DeathEvent.new(target.id, event.tick)
		game_state.event_resolver.add_event(death_event)
		
	print("%s takes %d damage (%d remaining)"
		% [target.display_name, event.amount, target.health])

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
		for effect: Effect in minion.effects:
			if effect.trigger == effect.Trigger.BATTLECRY:
				effect.source_player_id = player_id
				effect.source_entity_id = minion.id
				effect.apply_effect(game_state, event.battlecry_target_id)

	# Check for event trigger and add to listener list
	for effect: Effect in minion.effects:
		if effect.trigger_event_class:
			effect.source_player_id = minion.owner_id
			_register_listener(effect.trigger_event_class, effect)
	
	game_state.enchantment_manager.register_enchantments(minion.id)

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
		for effect in entity.effects:
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
# Solves what happens when a hero power is used
func handle_hero_power(event: HeroPowerEvent):
	var hero: Hero = game_state.heroes.get(event.player_id)
	var power: HeroPowerInfo = hero.hero_power
	
	game_state.mana[event.player_id] -= power.cost
	
	# -------------------------
	# Consume Hero power
	hero.on_hero_power(event.tick)
	
	# -------------------------
	# apply its effects
	for effect in hero.hero_power.effects:
		effect.source_entity_id = event.player_id
		effect.source_player_id = event.player_id
		effect.apply_effect(game_state, event.target_id)

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
