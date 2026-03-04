extends Resource
class_name CardInfo

# Base card class used for all cards.
# Spells use this base class directly because they have no additional data
# Other cards have their own subclasses (MinionCardInfo, WeaponCardInfo, etc.)

@export var id: String
@export var display_name: String
@export var cost: int

@export var requires_target: bool = false

@export var effects: Array[Effect] = []
