extends Resource
class_name CardInfo

# Base card class used for all cards.
# Spells use this base class directly because they have no additional data
# Other cards have their own subclasses (MinionCardInfo, WeaponCardInfo, etc.)

@export var id: String
@export var display_name: String
@export var cost: int
@export var effects: Array[Effect] = [] 

@export var target_type: Targeting.TargetType = Targeting.TargetType.NONE
@export var target_filters: Array[TargetFilter] = []
@export var target_optional: bool = false

@export var description: String
