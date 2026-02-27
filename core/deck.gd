extends Resource
class_name Deck

var cards: Array = []

func _init(initial_cards: Array = []):
	cards = initial_cards.duplicate()

func draw() -> Resource:
	if cards.is_empty():
		return null
	return cards.pop_front()

func shuffle(rng: RandomNumberGenerator) -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp
