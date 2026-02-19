extends RefCounted
class_name EventResolver

class Phase:
	var queue: Array
	var handler: Callable
	func _init(_queue: Array, _handler: Callable):
		queue = _queue
		handler = _handler

# -------------------------
# Event Queues
var draw_card_event_queue: Array[DrawCardEvent] = []
var play_card_event_queue: Array[PlayCardEvent] = []
var attack_event_queue: Array[AttackEvent] = []
var summon_event_queue: Array[SummonEvent] = []
var damage_event_queue: Array[DamageEvent] = []
var death_event_queue: Array[DeathEvent] = []

var phase_queues: Array[Phase] = []

# -------------------------
# id // used for deterministic ordering
var next_sequence_id: int = 0
const MAX_EVENTS_PER_TICK: int = 100

# -------------------------
# Managers
var resource_manager: ResourceManager
var combat_manager: CombatManager
var card_manager: CardManager

var game_state: GameState

func _init(_game_state: GameState):
	game_state = _game_state
	resource_manager = ResourceManager.new(game_state)
	combat_manager = CombatManager.new(game_state)
	card_manager = CardManager.new(game_state)
	
	# Define resolution order
	phase_queues = [
		Phase.new(draw_card_event_queue, Callable(card_manager, "handle_draw_card")),
		Phase.new(play_card_event_queue, Callable(card_manager, "handle_play_card")),
		Phase.new(attack_event_queue, Callable(combat_manager, "handle_attack")),
		Phase.new(summon_event_queue, Callable(combat_manager, "handle_summon")),
		Phase.new(damage_event_queue, Callable(combat_manager, "handle_damage")),
		Phase.new(death_event_queue, Callable(combat_manager, "handle_death"))
	]

# -------------------------
# Add events to their proper queue
func add_event(event: GameEvent):
	event.sequence_id = next_sequence_id
	next_sequence_id += 1
	if event is DrawCardEvent:
		draw_card_event_queue.append(event)
	elif event is PlayCardEvent:
		play_card_event_queue.append(event)
	elif event is AttackEvent:
		attack_event_queue.append(event)
	elif event is SummonEvent:
		summon_event_queue.append(event)
	elif event is DamageEvent:
		damage_event_queue.append(event)
	elif event is DeathEvent:
		death_event_queue.append(event)
	else:
		assert(false, "Unhandled event type: %s" % event)

func resolve() -> void:
	var processed_count: int = 0 # used to escape infinitely looping effects
	while _has_pending_events():
		for phase in phase_queues:
			
			if phase.queue.size() > 1:
				phase.queue.sort_custom(self._compare_events)
			
			while phase.queue.size() > 0 && processed_count <= MAX_EVENTS_PER_TICK:
				var event: GameEvent = phase.queue.pop_front()
				phase.handler.call(event)
				combat_manager.process_triggers(event)
				if not event.cancelled:
					game_state.emitted_events.append(event)
				processed_count += 1

# -------------------------
# Deterministic ordering
func _compare_events(a: GameEvent, b: GameEvent) -> int:
	if a.tick != b.tick:
		return a.tick - b.tick
	return a.sequence_id - b.sequence_id

# -------------------------
# elper functions
func _has_pending_events() -> bool:
	for phase in phase_queues:
		if phase.queue.size() > 0:
			return true
	return false
