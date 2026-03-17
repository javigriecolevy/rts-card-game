extends ActiveEnchantment
class_name BurnedEnchantment

@export var duration: int

var damage = 1 # future design space for increasing burn damage 

const TICKS_PER_SECOND = 100 #TODO: make global singleton for entire project = (1 / tickrate)

func _init() -> void:
	stackable = false
	expires_at_tick = applied_at_tick + (duration * TICKS_PER_SECOND)

# Deals damage to entity every second
func on_tick(entity_id: int, game_state: GameState) -> void:
	if (game_state.tick + applied_at_tick) % TICKS_PER_SECOND == 0:
		var entity: Entity = game_state.entities.get(entity_id)
		var damage_entity: DamageEvent = DamageEvent.new(entity.owner_id, entity_id, damage, game_state.tick)
		game_state.event_resolver.add_event(damage_entity)
