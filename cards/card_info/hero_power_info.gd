extends Resource
class_name HeroPowerInfo

@export var display_name: String = "hero power"
@export var description : String = "This hero power does nothin"

@export var cost : int = 2
@export var cooldown : int = 15

@export var target_type : Targeting.TargetType = Targeting.TargetType.NONE
@export var target_filters: Array[TargetFilter] = []
@export var target_optional: bool = false

@export var effects : Array[Effect] = []
