extends Effect
class_name DamageEffect

# -------------------------
# Config
@export var amount: int = 0

# -------------------------
# Targeting
func requires_target() -> bool:
	return true

func valid_targets(_game_state: GameState) -> Array:
	var targets: Array = []

	#for entity: Entity in game_state.entities.values():
	#	# Example rule: cannot target own hero
	#	if entity.owner_id != source_player_id:
	#		targets.append(entity.id)

	return targets

# -------------------------
# Queue damage event
func apply_effect(game_state: GameState, target_id: int) -> void:
	game_state.event_resolver.add_event(
			DamageEvent.new(
				source_entity_id,
				target_id,
				amount,
				game_state.tick
			)
		)
