extends RefCounted
class_name Entity

# -------------------------
# Identity
var id: int
var owner_id: int
var display_name: String

# -------------------------
# Combat stats
var ready_at_tick: int = 0
var attack_cooldown: int = 0
# Base stats (from card)
var base_attack: int = 0
var base_max_health: int = 0
# Current stats (after applying enchants)
var attack: int = 0
var health: int = 0
var max_health: int = 0

# -------------------------
# Enchantments List
var enchantments: Array[Enchantment] = []

# -------------------------
# Combat rules
func can_attack(current_tick: int) -> bool:
	return current_tick >= ready_at_tick and attack > 0

func on_attack(current_tick: int) -> void:
	ready_at_tick = current_tick + attack_cooldown
	print(display_name, " will be ready to attack at tick ", ready_at_tick, "it is currently: ", current_tick)
