extends Button
class_name MinionView

signal minion_clicked(minion_id)

var entity_id: int

func setup(minion: Minion, game_state: GameState):
	entity_id = minion.id
	update_stats(minion, game_state)

func update_stats(minion: Minion, game_state: GameState):
	text = "%s (%d/%d)" % [
		minion.display_name,
		minion.attack,
		minion.health
	]

func _pressed():
	minion_clicked.emit(entity_id)
