extends CardInfo
class_name MinionCardInfo

@export var attack: int = 0
@export var health: int = 0
@export var tribe: CardAttributes.TRIBE = CardAttributes.TRIBE.NONE
@export var attack_cooldown: int = 10
@export var enchantments: Array[Enchantment] = []
