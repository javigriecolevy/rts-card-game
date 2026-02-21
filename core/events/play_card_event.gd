extends GameEvent
class_name PlayCardEvent

var player_id: int
var card_instance_id: int
var card_name: String
var target_id: int
var card: CardInfo

func _init(_player_id: int = -1, _card_instance_id: int = -1, _target_id: int = -1, _tick: int = -1) -> void:
	player_id = _player_id
	card_instance_id = _card_instance_id
	target_id = _target_id
	tick = _tick
