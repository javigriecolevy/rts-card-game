extends Entity
class_name Hero

# -------------------------
# Card data
var card: HeroCardInfo

var hero_power: HeroPowerInfo
var hero_power_ready_tick : int = 0
var armor : int = 0

# Factory
static func new_hero(card_info: HeroCardInfo, owner_player_id: int, starting_health: int) -> Hero:
	var hero: Hero = Hero.new()
	
	# -------------------------
	# Identity
	hero.card = card_info
	hero.owner_id = owner_player_id
	hero.base_max_health = starting_health
	hero.display_name = "Player %d" % owner_player_id
	
	# -------------------------
	# Stats
	hero.health = hero.base_max_health
	hero.max_health = hero.base_max_health
	hero.hero_power = card_info.hero_power
	
	# -------------------------
	# Timing
	hero.attack_cooldown = 500
	hero.hero_power_ready_tick = 0
	
	# -------------------------
	# Enchant instanciating
	
	hero.enchantments = []
	for enchant in card_info.enchantments:
		hero.enchantments.append(enchant.duplicate(true))
	
	return hero

func on_hero_power(current_tick: int) -> void:
	hero_power_ready_tick = current_tick + card.hero_power.cooldown
