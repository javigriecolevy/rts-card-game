extends RefCounted
class_name GameState

# -------------------------
# Core game data
var tick: int = 0
var cycle_length: int = 2

# -------------------------
# Entity system
var next_entity_id: int = 1
var entities: Dictionary[int, Entity] = {}   # entity_id -> Entity
var heroes: Dictionary[int, int] = {}        # player_id -> hero_entity_id

# -------------------------
# Card instance system
var next_card_instance_id: int = 1
var card_instances: Dictionary[int, CardInstance] = {}  # id -> CardInstance

# -------------------------
# Death resolution
var pending_deaths: Array[int] = []

# -------------------------
# Event System
var event_resolver: EventResolver = EventResolver.new(self)

# -------------------------
# Player data
var decks: Dictionary[int, Deck] = {}
var hands: Dictionary = {}                   # player_id -> Array[int]
var boards: Dictionary[int, Array] = {}      # player_id -> Array[Minion]

var mana: Dictionary[int, int] = {}          # player_id -> int (current mana)
var max_mana: Dictionary[int, int] = {}      # player_id -> int
var max_mana_limit: int = 10

# -------------------------
# Command queue
var command_queue: Array[GameCommand] = []

# -------------------------
# Simulation output (UI / replay / networking) Cleared externally once consumed
var serialized_emitted_events: Array[Dictionary]
var UI_emitted_events: Array[GameEvent]

# -------------------------
#  Event emitter helper
func emit(event: GameEvent) -> void:
	serialized_emitted_events.append(event.serialize())

func emit_ui(event: GameEvent):
	UI_emitted_events.append(event)

# -------------------------
# Entity ID helper
func _allocate_entity_id() -> int:
	var id: int = next_entity_id
	next_entity_id += 1
	return id

# -------------------------
# Card instance ID helper
func _allocate_card_instance_id() -> int:
	var id: int = next_card_instance_id
	next_card_instance_id += 1
	return id

func remove_entity(entity: Entity) -> void:
	if entity is Minion:
		boards[entity.owner_id] = boards[entity.owner_id].filter(func(m): return m.id != entity.id)
	elif entity is Hero:
		print("Player %d has been defeated!" % entity.owner_id)
	# Remove entity from registry
	entities.erase(entity.id)

# -------------------------
# Debug output #TODO: move to UI module
func print_current_state() -> void:
	for pid in heroes.keys():
		var hero: Hero = entities.get(heroes[pid])
		if hero:
			print("Player %d hero: %d/%d"
				% [pid, hero.health, hero.max_health])

	for pid in boards.keys():
		var board_info: Array = []
		for m: Minion in boards[pid]:
			board_info.append("%s (%d/%d)"
				% [m.display_name, m.attack, m.health])
		print("Player %d board: %s" % [pid, board_info])

	for pid in mana.keys():
		print("Player %d mana: %d/%d"
			% [pid, mana[pid], max_mana[pid]])
	
	for pid in hands.keys():
		var hand_info: Array = []
		for c in hands[pid]:
			hand_info.append("%s" % c)
		print("Player %d hand: %s" % [pid, hand_info])
