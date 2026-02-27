extends Resource
class_name CardInfo

@export var id: String
@export var display_name: String
@export var cost: int

enum CardType {MINION, SPELL}
@export var type: CardType = CardType.MINION
@export var requires_target: bool = false

# For minions
@export var attack: int = 0
@export var health: int = 0
@export var attack_cooldown: int = 10

# Effects trigger events
@export var effects: Array[Effect] = []
