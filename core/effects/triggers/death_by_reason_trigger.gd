extends EffectTrigger
class_name DeathByReasonTrigger

@export var reason: DamageEvent.DAMAGE_REASON

# -------------------------
# Returns true a minion dies from specific reason (Burn, Spell, Combat, etc. ) 
func should_trigger(event: GameEvent) -> bool:
	if event is DeathEvent:
		if event.killing_blow == reason:
			return true
	return false
