extends Button
class_name HeroView

signal hero_clicked(hero_id)

var entity_id: int

func setup(hero):
	entity_id = hero.id
	update_stats(hero)

func update_stats(hero):
	text = "%s (%d/%d)" % [
		hero.display_name,
		hero.health,
		hero.max_health
	]

func _pressed():
	hero_clicked.emit(entity_id)
