extends RefCounted
class_name Targeting


static func get_valid_targets(
	game_state,
	target_type,
	player_id,
	filters: Array[TargetFilter] = []
) -> Array:

	var result: Array = []

	for entity in _get_targets_by_type(game_state, target_type, player_id):

		if _passes_filters(entity, filters):
			result.append(entity.id)

	return result



static func _passes_filters(entity: Entity, filters: Array[TargetFilter]) -> bool:

	for filter in filters:
		if not filter.passes(entity):
			return false

	return true



static func _get_targets_by_type(game_state, target_type, player_id) -> Array:

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



static func _get_minions(game_state, player_id) -> Array:
	var result := []

	for entity in game_state.entities.values():
		if entity.owner_id == player_id and entity.is_minion:
			result.append(entity)

	return result



static func _get_all_minions(game_state) -> Array:
	var result := []

	for entity in game_state.entities.values():
		if entity.is_minion:
			result.append(entity)

	return result



static func _get_characters(game_state, player_id) -> Array:
	var result := []

	for entity in game_state.entities.values():
		if entity.owner_id == player_id and entity.is_character:
			result.append(entity)

	return result



static func _get_all_characters(game_state) -> Array:
	var result := []

	for entity in game_state.entities.values():
		if entity.is_character:
			result.append(entity)

	return result



static func _get_enemy_id(game_state, player_id):

	for id in game_state.players:
		if id != player_id:
			return id

	return -1
