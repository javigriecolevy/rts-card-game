extends Node
class_name CardDatabase

# Dictionary mapping
var card_id_to_index: Dictionary[String, int] = {} # id(internal name) -> index
var index_to_card: Dictionary[int, CardInfo] = {}  # index -> CardInfo Resource

# Bitset flag mapping
var by_cost: Dictionary[int, CardBitset] = {}                       # cost->card index array
var by_class: Dictionary[CardAttributes.CLASS, CardBitset] = {}     # class->card index array
var by_tribe: Dictionary[CardAttributes.TRIBE, CardBitset] = {}     # tribe->card index array
var by_keyword: Dictionary[CardAttributes.KEYWORD, CardBitset] = {} # keyword->card index array

# Bitset helper class
var card_bitset: CardBitset

func _ready():
	_load_cards()
	print("CardDatabase loaded:", card_id_to_index.keys())

# -------------------------
# Load all .tres card resources from card_info folder
func _load_cards():
	var dir = DirAccess.open("res://cards/resources")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var current_index: int = 0
		card_bitset = CardBitset.new()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var path = "res://cards/resources/" + file_name
				var card_res = ResourceLoader.load(path)
				if card_res:
					var card_id = card_res.get("id")  # safe way to access
					if card_id != null and card_id != "":
						register_card(card_res, current_index)
						current_index += 1
						print("Loaded card:", card_id)
					else:
						print("Card missing id:", path)
				else:
					print("Failed to load card:", path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open cards/resources folder!")

func register_card(card_res: CardInfo, index: int):
	card_bitset.set_bit(index)
	card_id_to_index[card_res.id] = index
	index_to_card[index] = card_res
	
	if not by_cost.has(card_res.cost):
		by_cost[card_res.cost] = CardBitset.new()
	by_cost[card_res.cost].set_bit(index)
	
	if not by_class.has(card_res.class_type):
		by_class[card_res.class_type] = CardBitset.new()
	by_class[card_res.class_type].set_bit(index)
	
	#if card_res is MinionCardInfo:
		#if not by_tribe.has(card_res.tribe):
			#by_tribe[card_res.tribe] = CardBitset.new()
		#by_tribe[card_res.tribe].set_bit(index)

# -------------------------
# Get a card by ID
func get_card_by_id(card_id: String) -> CardInfo:
	if card_id in card_id_to_index:
		var index: int = card_id_to_index[card_id]
		return get_card_by_index(index)
	print("Card id not found:", card_id)
	return null

# -------------------------
# Get a card by index
func get_card_by_index(index: int) -> CardInfo:
	if index in index_to_card:
		return index_to_card[index].duplicate() # duplicate to not modify resource
	print("Card index not found:", index)
	return null

# -------------------------
# bitset filtering
func get_random_card_from_bitset(bitset: CardBitset, rng: RandomNumberGenerator) -> CardInfo:
	var cards_array: Array[CardInfo] = get_cards_from_bitset(bitset)
	if cards_array.size() == 0:
		return null
	var random_index: int = rng.randi_range(0, cards_array.size() - 1)
	return cards_array[random_index]

func get_cards_from_bitset(bitset: CardBitset) -> Array[CardInfo]:
	var cards_array: Array[CardInfo] = []
	# Iterate over all indices that have their bits set
	for index: int in bitset.to_indices():
		if index in index_to_card:
			cards_array.append(get_card_by_index(index))
	
	return cards_array

func get_bitset_by_cost(cost: int) -> CardBitset:
	if cost in by_cost:
		return by_cost[cost]
	return CardBitset.new()  # empty bitset if no cards

func get_bitset_by_class(class_type: CardAttributes.CLASS) -> CardBitset:
	if class_type in by_class:
		return by_class[class_type]
	return CardBitset.new()

func get_bitset_by_tribe(tribe: CardAttributes.TRIBE) -> CardBitset:
	if tribe in by_tribe:
		return by_tribe[tribe]
	return CardBitset.new()

func get_bitset_by_keyword(keyword: CardAttributes.KEYWORD) -> CardBitset:
	if keyword in by_keyword:
		return by_keyword[keyword]
	return CardBitset.new()
