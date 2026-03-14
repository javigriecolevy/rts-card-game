extends RefCounted
class_name Targeting

enum TargetType {
	NONE,
	FRIENDLY_MINION,
	ENEMY_MINION,
	ANY_MINION,
	FRIENDLY_CHARACTER,
	ENEMY_CHARACTER,
	ANY_CHARACTER
}

static func get_attack_targets(attacker_id: int, game_state: GameState) -> Array[int]:
	var attacker: Entity = game_state.entities[attacker_id]
	var enemy_id: int = _get_enemy_id(game_state, attacker.owner_id)
	var targets: Array[int] = _get_characters(game_state, enemy_id)
	
	targets = _remove_stealthed(targets, game_state)
	targets = _apply_taunt_rule(targets, game_state)
	
	return targets

static func _apply_taunt_rule(targets: Array[int], game_state: GameState) -> Array[int]:
	var entities_with_taunt: Array[int] = []
	var taunt_filter: TargetFilter = HasEnchantmentFilter.new(TauntEnchantment)
	for entity_id in targets:
		if _passes_filters(game_state.entities.get(entity_id), [taunt_filter]):
			entities_with_taunt.append(entity_id)
	if entities_with_taunt.is_empty():
		return targets
	return entities_with_taunt

static func _remove_stealthed(targets: Array[int], game_state: GameState) -> Array[int]:
	var stealth_filter: TargetFilter = HasEnchantmentFilter.new(StealthEnchantment)
	for entity_id in targets:
		if _passes_filters(game_state.entities.get(entity_id), [stealth_filter]):
			targets.erase(entity_id)
	return targets

static func get_valid_targets(player_id: int, target_type: TargetType, filters: Array[TargetFilter], game_state: GameState) -> Array[int]:
	var result: Array[int] = []
	
	for entity_id in _get_targets_by_type(player_id, target_type, game_state):
		if _passes_filters(game_state.entities.get(entity_id), filters):
			result.append(entity_id)
	
	return result

static func _passes_filters(entity: Entity, filters: Array[TargetFilter]) -> bool:
	for filter in filters:
		if not filter.passes(entity):
			return false
	
	return true

static func _get_targets_by_type(player_id: int, target_type: TargetType, game_state: GameState) -> Array[int]:
	match target_type:
		TargetType.NONE:
			return []
		
		TargetType.FRIENDLY_MINION:
			return _get_minions(game_state, player_id)
		
		TargetType.ENEMY_MINION:
			return _get_minions(game_state, _get_enemy_id(game_state, player_id))
		
		TargetType.ANY_MINION:
			return _get_all_minions(game_state)
		
		TargetType.FRIENDLY_CHARACTER:
			return _get_characters(game_state, player_id)
		
		TargetType.ENEMY_CHARACTER:
			return _get_characters(game_state, _get_enemy_id(game_state, player_id))
		
		TargetType.ANY_CHARACTER:
			return _get_all_characters(game_state)
	
	return []



static func _get_minions(game_state: GameState, player_id) -> Array[int]:
	var result: Array[int] = []
	
	for entity: Entity in game_state.entities.values():
		if entity.owner_id == player_id and entity is Minion:
			result.append(entity.id)
	
	return result

static func _get_all_minions(game_state: GameState) -> Array[int]:
	var result: Array[int] = []
	
	for entity: Entity in game_state.entities.values():
		if entity is Minion:
			result.append(entity.id)
	
	return result

static func _get_characters(game_state: GameState, player_id) -> Array[int]:
	var result: Array[int] = []
	
	for entity: Entity in game_state.entities.values():
		if entity.owner_id == player_id:
			result.append(entity.id)
	
	return result

static func _get_all_characters(game_state: GameState) -> Array[int]:
	return game_state.entities.keys()

static func _get_enemy_id(game_state: GameState, player_id):
	for id in game_state.boards.keys():
		if id != player_id:
			return id
	return -1
