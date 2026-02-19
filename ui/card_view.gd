extends Button
class_name CardView

signal card_clicked(card_instance_id)

var card_id: int

func setup(instance_id: int, definition):
	card_id = instance_id
	text = "%s (Cost %d)" % [
		definition.display_name,
		definition.cost
	]

func _pressed():
	print("Selected card %d", card_id)
	card_clicked.emit(card_id)
