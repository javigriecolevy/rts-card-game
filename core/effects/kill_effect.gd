extends Effect
class_name KillEffect

# -------------------------
# Queues kill event
func apply_effect(game_state: GameState) -> void:
	if target_id == -1 && game_state.entities.get(target_id) is not Hero:
		return
	var death_event: DeathEvent = DeathEvent.new(target_id, game_state.tick)
	game_state.event_resolver.add_event(death_event)
