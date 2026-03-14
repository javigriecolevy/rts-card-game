extends Effect
class_name SelfDamageEffect

# -------------------------
# Config
@export var amount : int = 0

# -------------------------
# adds the attack and health values to the minions stats as buffs
func apply_effect(game_state: GameState, _target_id: int) -> void:
	if game_state.entities.get(source_player_id) is Hero:
			game_state.event_resolver.add_event(
			DamageEvent.new(
				source_entity_id,
				source_player_id,
				amount,
				game_state.tick
			)
		)
