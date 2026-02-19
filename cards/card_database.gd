extends Node
class_name CardDatabase

# Dictionary mapping card_id -> CardInfo Resource
var cards : Dictionary = {}

# Called when this node enters the scene tree
func _ready():
	_load_cards()
	print("CardDatabase loaded:", cards.keys())

# -------------------------
# Load all .tres card resources from card_info folder
# -------------------------
func _load_cards():
	var dir = DirAccess.open("res://cards/card_info")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var path = "res://cards/card_info/" + file_name
				var card_res = ResourceLoader.load(path)
				if card_res:
					var card_id = card_res.get("id")  # safe way to access
					if card_id != null and card_id != "":
						cards[card_id] = card_res
						print("Loaded card:", card_id)
					else:
						print("Card missing id:", path)
				else:
					print("Failed to load card:", path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open cards/card_info folder!")
# -------------------------
# Get a card by ID
# -------------------------
func get_card(id: String) -> Resource:
	if id in cards:
		# Return a copy to avoid mutating the original resource
		return cards[id].duplicate()
	print("Card not found:", id)
	return null
