extends ActiveEnchantment
class_name PoisonEnchantment

func _init() -> void:
	stackable = false

# Kills any minion damaged by this
func on_damage_dealt(_entity_id: int, game_state: GameState, target_id: int):
	if game_state.entities.get(target_id) is Minion:
		var death_event: DeathEvent = DeathEvent.new(target_id, game_state.tick)
		game_state.event_resolver.add_event(death_event)
