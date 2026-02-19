extends GameEvent
class_name PlayCardEvent

var player_id: int
var card_instance_id: int
var card_name: String
var target_id: int
var card: CardInfo

func _init(_player_id: int, _card_instance_id: int, _target_id: int, _tick: int) -> void:
	player_id = _player_id
	card_instance_id = _card_instance_id
	target_id = _target_id
	tick = _tick
