extends ActiveEnchantment
class_name TimedTriggerEffectEnchantment

@export var time_interval: int
@export var effect: Effect

const TICKS_PER_SECOND = 100 #TODO: make global singleton for entire project = (1 / tickrate)

# after time_interval has passed, perform the effect
func on_tick(entity_id: int, game_state: GameState) -> void:
	if not expires_at_tick:
		expires_at_tick = game_state.tick + (time_interval * TICKS_PER_SECOND) + 1
	if (game_state.tick + applied_at_tick) % (time_interval * TICKS_PER_SECOND) == 0:
		effect = effect.duplicate()
		effect.source_entity_id = entity_id
		effect.source_player_id = game_state.entities.get(entity_id).owner_id
		effect.apply_effect(game_state, entity_id)
		applied_at_tick = game_state.tick
		expires_at_tick += (time_interval * TICKS_PER_SECOND) + 1
