extends CardInfo
class_name HeroCardInfo

@export var health: int = 0
@export var armor: int = 0
@export var attack_cooldown: int = 10

@export var hero_power: HeroPowerInfo

@export var enchantments: Array[Enchantment] = []
