extends Resource
class_name Effect

# -------------------------
# Trigger type
enum Trigger {
	MANUAL,
	BATTLECRY,
	DEATHRATTLE
}
#only lifecycle / manual triggers
@export var trigger: Trigger = Trigger.MANUAL

# Only for event-driven effects: on_summon, on_attack, on_death, on_damage, etc.
@export var trigger_event_class: Script = null

# -------------------------
# Source context
var source_player_id: int = -1
var source_entity_id: int = -1

# -------------------------
# Targeting
func requires_target() -> bool:
	return false

func valid_targets(_game_state: GameState) -> Array:
	return []

# -------------------------
# Apply effect to a target entity (-1 for global / no-target effects)
func apply_effect(_game_state: GameState, _target_entity_id: int) -> void:
	pass # override in subclasses
