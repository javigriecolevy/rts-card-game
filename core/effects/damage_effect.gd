extends Effect
class_name DamageEffect

# -------------------------
# Config
@export var amount: int = 0
@export var reason: DamageEvent.DAMAGE_REASON = DamageEvent.DAMAGE_REASON.COMBAT

# -------------------------
# Queue damage event
func apply_effect(game_state: GameState) -> void:
	if target_id == -1:
		return
	
	game_state.event_resolver.add_event(
			DamageEvent.new(
				source_entity_id,
				target_id,
				amount,
				game_state.tick,
				reason
			)
		)
