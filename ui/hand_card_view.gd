extends Button
class_name HandCardView

signal card_clicked(card_instance_id)

var card_id: int

func setup(instance_id: int, definition: CardInfo):
	card_id = instance_id
	$CardView.setup(definition)

func _pressed():
	print("Selected card %d", card_id)
	card_clicked.emit(card_id)
