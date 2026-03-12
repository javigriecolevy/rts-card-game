extends Button
class_name HeroPowerView

signal hero_clicked(hero_id)

var entity_id: int

func setup(hero: Hero):
	entity_id = hero.id
	update_stats(hero)

func update_stats(hero: Hero):
	text = "%s (%d/%d)" % [
		hero.display_name,
		hero.health,
		hero.max_health
	]

func _pressed():
	hero_clicked.emit(entity_id)
