extends Resource
class_name Deck

var cards: Array = []

func _init(initial_cards: Array = []):
	cards = initial_cards.duplicate()

func draw() -> Resource:
	if cards.is_empty():
		return null
	return cards.pop_front()

func shuffle():
	cards.shuffle()
