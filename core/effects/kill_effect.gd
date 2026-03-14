extends Effect
class_name KillEffect

# -------------------------
# Queue kill event
func apply_effect(game_state: GameState, target_id: int) -> void:
	if target_id == -1 && target_id != 1 && target_id != 2: #TODO: fix to check that its not a hero
		return
	var death_event: DeathEvent = DeathEvent.new(target_id, game_state.tick)
	game_state.event_resolver.add_event(death_event)
