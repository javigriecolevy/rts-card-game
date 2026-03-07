extends Button
class_name MinionView

signal minion_clicked(minion_id)

var entity_id: int

func setup(minion: Minion):
	entity_id = minion.id
	$CardView.setup(minion.card)
	$CardView.minion_setup()
	update_stats(minion)

func update_stats(minion: Minion):
	#text = "%s (%d/%d)" % [
		#minion.display_name,
		#minion.attack,
		#minion.health
	#]

	$CardView/HealthLabel.text = str(minion.health)
	$CardView/AttackLabel.text = str(minion.attack)
func _pressed():
	minion_clicked.emit(entity_id)
