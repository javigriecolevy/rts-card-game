extends Node
class_name CardDatabase

# Dictionary mapping
var card_id_to_index: Dictionary[String, int] = {} # id(internal name) -> index
var index_to_card: Dictionary[int, CardInfo] = {}  # index -> CardInfo Resource

# Bitset flag mapping
var by_cost: Dictionary[int, CardBitset] = {}                       # cost -> card index array
var by_class: Dictionary[CardAttributes.CLASS, CardBitset] = {}     # class -> card index array
var by_type: Dictionary[CardAttributes.CARDTYPE, CardBitset] = {} 	# cardtype -> card index array
var by_tribe: Dictionary[CardAttributes.TRIBE, CardBitset] = {}     # tribe -> card index array
var by_keyword: Dictionary[CardAttributes.KEYWORD, CardBitset] = {} # keyword -> card index array

# Bitset helper class
var card_bitset: CardBitset

func _ready():
	
	# -------------------------
	# Initilize all dictionaries with empty card bitsets
	for cost in range(0, 11):  # Increase range if any card costs more than 10
		by_cost[cost] = CardBitset.new()
	for class_type in CardAttributes.CLASS.values():
		by_class[class_type] = CardBitset.new()
	for type in CardAttributes.CARDTYPE.values():
		by_type[type] = CardBitset.new()
	for tribe in CardAttributes.TRIBE.values():
		by_tribe[tribe] = CardBitset.new()
	for keyword in CardAttributes.KEYWORD.values():
		by_keyword[keyword] = CardBitset.new()
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
	
	if card_res.collectible:
		by_cost[card_res.cost].set_bit(index)
		by_class[card_res.class_type].set_bit(index)
		if card_res is MinionCardInfo:
			by_type[CardAttributes.CARDTYPE.MINION].set_bit(index)
			by_tribe[card_res.tribe].set_bit(index)
			register_minion_keywords(card_res, index)
	#	elif card_res is WeaponCardInfo:
	#		by_type[CardAttributes.CARDTYPE.WEAPON].set_bit(index)
		#elif card_res is HeroCardInfo // dont think hero cards should be generetable
			#by_type[CardAttributes.CARDTYPE.HERO].set_bit(intex) // so this is reduntant
		elif card_res is CardInfo:
			by_type[CardAttributes.CARDTYPE.SPELL].set_bit(index)

func register_minion_keywords(card: MinionCardInfo, index: int):
	for enchant in card.enchantments:
		if enchant is DivineShieldEnchantment:
			by_keyword[CardAttributes.KEYWORD.DIVINE_SHIELD].set_bit(index)
		elif enchant is StealthEnchantment:
			by_keyword[CardAttributes.KEYWORD.STEALTH].set_bit(index)
		elif enchant is TauntEnchantment:
			by_keyword[CardAttributes.KEYWORD.TAUNT].set_bit(index)
		elif enchant is EvasiveEnchantment:
			by_keyword[CardAttributes.KEYWORD.EVASIVE].set_bit(index)
	
	for effect in card.effects:
		if effect.trigger == effect.Trigger.BATTLECRY:
			by_keyword[CardAttributes.KEYWORD.BATTLECRY].set_bit(index)
		elif effect.trigger == effect.Trigger.DEATHRATTLE:
			by_keyword[CardAttributes.KEYWORD.DEATHRATTLE].set_bit(index)

# -------------------------
# getters helper functions
func get_card_by_id(card_id: String) -> CardInfo:
	if card_id in card_id_to_index:
		var index: int = card_id_to_index[card_id]
		return get_card_by_index(index)
	print("Card id not found:", card_id)
	return null

func get_card_by_index(index: int) -> CardInfo:
	if index in index_to_card:
		return index_to_card[index].duplicate() # duplicate to not modify resource
	print("Card index not found:", index)
	return null

# -------------------------
# bitset filtering getters
func get_random_card_from_bitset(bitset: CardBitset, rng: RandomNumberGenerator) -> CardInfo:
	var set_indices = bitset.to_indices()
	var num_set_bits = set_indices.size()
	if num_set_bits == 0: # EMPTY BITSET, GAME WILL CRASH
		return null # TODO: return easter egg card (will prevent crash)
	
	var random_index = rng.randi_range(0, num_set_bits - 1)
	var set_index = set_indices[random_index]
	 
	return get_card_by_index(set_index)

func get_all_cards_from_bitset(bitset: CardBitset) -> Array[CardInfo]:
	var cards_array: Array[CardInfo] = []
	# Iterate over all indices that have their bits set
	for index: int in bitset.to_indices():
		if index in index_to_card:
			cards_array.append(get_card_by_index(index))
	
	return cards_array

func get_bitset_by_cost(cost: int) -> CardBitset:
	return by_cost[cost]

func get_bitset_by_class(class_type: CardAttributes.CLASS) -> CardBitset:
	return by_class[class_type]

func get_bitset_by_tribe(tribe: CardAttributes.TRIBE) -> CardBitset:
	return by_tribe[tribe]

func get_bitset_by_keyword(keyword: CardAttributes.KEYWORD) -> CardBitset:
	return by_keyword[keyword]
