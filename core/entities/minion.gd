extends Entity
class_name Minion

# -------------------------
# Card data
var card: CardInfo

# -------------------------
# Combat stats
var attack: int
var ready_at_tick: int = 0

# -------------------------
# Factory
static func new_from_card(card_info: CardInfo, owner_player_id: int, current_tick: int) -> Minion:
	var minion: Minion = Minion.new()

	# -------------------------
	# Identity
	minion.owner_id = owner_player_id
	minion.card = card_info
	minion.display_name = card_info.display_name

	# -------------------------
	# Stats
	minion.attack = card_info.attack
	minion.health = card_info.health
	minion.max_health = card_info.health

	# -------------------------
	# Timing
	minion.ready_at_tick = current_tick + card_info.attack_cooldown

	return minion

# -------------------------
# Combat rules
func can_attack(current_tick: int) -> bool:
	return current_tick >= ready_at_tick
func on_attack(current_tick: int) -> void:
	ready_at_tick = current_tick + card.attack_cooldown


# -------------------------
# ! UNUSED FUNC, PONDERING IF SHOULD BE USED OR NOT.
# Returns all effects on this card for the given trigger type.
func _get_effects(trigger_type: Effect.Trigger) -> Array:
	var matching_effects: Array = []
	for e in card.effects:
		if e.trigger == trigger_type:
			matching_effects.append(e)
	return matching_effects
