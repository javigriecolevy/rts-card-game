extends Button
class_name MinionView

signal minion_clicked(minion_id)

var entity_id: int

func setup(minion):
	entity_id = minion.id
	update_stats(minion)

func update_stats(minion):
	text = "%s (%d/%d)" % [
		minion.display_name,
		minion.attack,
		minion.health
	]

func _pressed():
	minion_clicked.emit(entity_id)
