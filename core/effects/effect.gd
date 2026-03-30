extends Resource
class_name Effect

# -------------------------
# What causes effect to trigger
@export var trigger: EffectTrigger = EffectTrigger.new()

# -------------------------
# Source context
var source_player_id: int = -1
var source_entity_id: int = -1

# target entity (-1 for global / no-target effects)
var target_id: int = -1

# -------------------------
# Override in subclasses
func apply_effect(_game_state: GameState) -> void:
	pass 
