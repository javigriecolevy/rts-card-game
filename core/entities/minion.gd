extends Entity
class_name Minion

# -------------------------
# Card data
var card: MinionCardInfo

# -------------------------
# Effect list
var effects: Array[Effect] = []

# -------------------------
# Factory
static func new_from_card(card_info: MinionCardInfo, owner_player_id: int, current_tick: int) -> Minion:
	var minion: Minion = Minion.new()

	# -------------------------
	# Identity
	minion.owner_id = owner_player_id
	minion.card = card_info
	minion.display_name = card_info.display_name

	# -------------------------
	# Stats
	minion.base_attack = card_info.attack
	minion.base_max_health = card_info.health
	
	minion.attack = minion.base_attack
	minion.health = minion.base_max_health
	minion.max_health = minion.base_max_health

	# -------------------------
	# Timing
	minion.attack_cooldown = card_info.attack_cooldown
	minion.ready_at_tick = current_tick + card_info.attack_cooldown
	
	# -------------------------
	# Effect/Enchant instanciating
	minion.effects = card_info.effects.duplicate(true)
	
	minion.enchantments = []
	for enchant in card_info.enchantments:
		minion.enchantments.append(enchant.duplicate(true))

	return minion

# -------------------------
# ! UNUSED FUNC, PONDERING IF SHOULD BE USED OR NOT.
# Returns all effects on this card for the given trigger type.
func _get_effects(trigger_type: Effect.Trigger) -> Array:
	var matching_effects: Array = []
	for e in card.effects:
		if e.trigger == trigger_type:
			matching_effects.append(e)
	return matching_effects
