extends RefCounted
class_name EnchantmentManager

var game_state: GameState

var entities_with_active_enchant: Dictionary = {}
var entities_by_enchant_expiration_tick: Dictionary[int, Array] # tick -> Array[Entity_id]
var dirty_entities: Dictionary = {} # entity.id

signal entity_recalculated(entity_id: int)

func _init(_game_state: GameState) -> void:
	game_state = _game_state

func apply_enchantment(entity_id: int, enchantment: Enchantment):
	var entity: Entity = game_state.entities.get(entity_id)
	entity.enchantments.append(enchantment)
	recalculate_entity(entity)
	register_enchantments(entity_id)
	
func register_enchantments(entity_id: int):
	print("REGISTERING ENCHANTMENT")
	var entity: Entity = game_state.entities.get(entity_id)
	var has_active_enchant = false
	for enchantment in entity.enchantments:
		if enchantment.expires_at_tick:
			if not entities_by_enchant_expiration_tick.has(enchantment.expires_at_tick):
				entities_by_enchant_expiration_tick[enchantment.expires_at_tick] = []
			entities_by_enchant_expiration_tick[enchantment.expires_at_tick].append(entity_id)
		
		if not has_active_enchant and enchantment is ActiveEnchantment:
			has_active_enchant = true
	if has_active_enchant:
		entities_with_active_enchant[entity_id] = true
	else:
		entities_with_active_enchant.erase(entity_id)

func on_tick():
	for entity_id in entities_with_active_enchant:
		var entity: Entity = game_state.entities.get(entity_id)
		if entity:
			print("CALLING ONTICK ON REGISTERED ENCHANTMENT")
			for enchant in entity.enchantments:
				if enchant is ActiveEnchantment:
					enchant.on_tick(entity_id, game_state)
		else:
			entities_with_active_enchant.erase(entity_id)

func mark_dirty(entity_id: int):
	dirty_entities[entity_id] = true

func recalculate_dirty_entities():
	for entity_id in dirty_entities.keys():
		var entity = game_state.entities.get(entity_id)
		if entity:
			recalculate_entity(entity)
			register_enchantments(entity_id)
	dirty_entities.clear()

func recalculate_entity(entity: Entity) -> void:
	var damage_taken = entity.max_health - entity.health
	
	# Reset base stats
	entity.attack = entity.base_attack
	entity.max_health = entity.base_max_health
	entity.health = min(entity.health, entity.max_health)
	
	# Apply each stat modifier and remove expired enchants
	for enchantment : Enchantment in entity.enchantments:
		if enchantment.expires_at_tick && enchantment.expires_at_tick <= game_state.tick:
			entity.enchantments.erase(enchantment)
		elif  enchantment is StatEnchantment:
			apply_stat_modifier(entity, enchantment)
	entity.health = entity.max_health - damage_taken
	emit_signal("entity_recalculated", entity.id)

func apply_stat_modifier(entity: Entity, enchantment: StatEnchantment):
	if enchantment.stat == enchantment.StatType.ATTACK:
		entity.attack = _apply_stat_mode(entity.attack, enchantment)
	if enchantment.stat == enchantment.StatType.HEALTH:
		entity.max_health = _apply_stat_mode(entity.max_health, enchantment)

func _apply_stat_mode(current_value: int, enchantment: StatEnchantment) -> int:
	match enchantment.mode:
		StatEnchantment.Mode.ADD:
			return max(0, current_value + enchantment.value)
		StatEnchantment.Mode.SET:
			return max(0, enchantment.value)
		StatEnchantment.Mode.MULT:
			return max(0, int(current_value * enchantment.value))
	return 0 # ERROR: UNHANDLED MODE TYPE

func sweep_expired_enchantments(tick: int):
	if entities_by_enchant_expiration_tick.has(tick):
		for entity_id in entities_by_enchant_expiration_tick.get(tick):
			var entity: Entity = game_state.entities.get(entity_id)
			if entity:
				for enchantment : Enchantment in entity.enchantments:
					if enchantment.expires_at_tick and enchantment.expires_at_tick <= game_state.tick:
						mark_dirty(entity_id)
						break
