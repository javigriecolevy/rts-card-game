extends Button
class_name MinionView

@export var card_view: CardView
@export var VFXLayer: Control
@export var AttackGlow: TextureRect

signal minion_clicked(minion_id)

var entity_id: int

func setup(minion: Minion):
	AttackGlow.material = AttackGlow.material.duplicate()
	entity_id = minion.id
	card_view.setup(minion.card)
	card_view.minion_setup()
	update_stats(minion)

func update_stats(minion: Minion):
	card_view.HealthLabel.text = str(minion.health)
	card_view.AttackLabel.text = str(minion.attack)
	#TODO: Change Label color if the stat is higher or lower than on the minion.card

func update_can_attack_view(enabled: bool):
	if enabled:
		AttackGlow.material.set_shader_parameter("glow_strength", 10.0)
	else:
		AttackGlow.material.set_shader_parameter("glow_strength", 0.0)


func _pressed():
	minion_clicked.emit(entity_id)
