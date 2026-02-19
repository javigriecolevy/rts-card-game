extends Entity
class_name Hero
# Factory
static func new_hero(owner_player_id: int, starting_health: int) -> Hero:
	var hero: Hero = Hero.new()

	hero.owner_id = owner_player_id
	hero.health = starting_health
	hero.max_health = starting_health
	hero.display_name = "Player %d" % owner_player_id

	return hero
