extends ActiveEnchantment
class_name BurnedEnchantment

@export var duration: int

var starting_tick
var damage = 1 # future design space for increasing burn damage 

const TICKS_PER_SECOND = 100 #TODO: make global singleton for entire project = (1 / tickrate)

func _init() -> void:
	stackable = false

# Deals damage to entity every second
# TODO: make additional burn enchantments add to the timer of existing burn enchants instead of stacking
func on_tick(entity_id: int, game_state: GameState) -> void:
	var entity: Entity = game_state.entities.get(entity_id)
	if not starting_tick:
		starting_tick = game_state.tick
		expires_at_tick = game_state.tick + (duration * TICKS_PER_SECOND)
		game_state.enchantment_manager.mark_dirty(entity_id)
	if (game_state.tick + starting_tick) % TICKS_PER_SECOND == 0:
		var damage_entity: DamageEvent = DamageEvent.new(entity.owner_id, entity_id, damage, game_state.tick)
		game_state.event_resolver.add_event(damage_entity)
