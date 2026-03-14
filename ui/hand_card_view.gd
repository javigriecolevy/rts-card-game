extends Button
class_name HandCardView

@export var AffordGlow: TextureRect

signal card_clicked(card_instance_id)

var card_id: int

func setup(instance_id: int, definition: CardInfo):
	AffordGlow.material = AffordGlow.material.duplicate()
	card_id = instance_id
	$CardView.setup(definition)

func update_can_afford_glow(enabled: bool):
	if enabled:
		AffordGlow.material.set_shader_parameter("glow_strength", 10.0)
	else:
		AffordGlow.material.set_shader_parameter("glow_strength", 0.0)

func is_selected(enabled: bool):
	if enabled:
		AffordGlow.material.set_shader_parameter("pulse_speed", 5.5)
		AffordGlow.material.set_shader_parameter("glow_color", Color.ORANGE)
	else:
		AffordGlow.material.set_shader_parameter("pulse_speed", 0.0)
		AffordGlow.material.set_shader_parameter("glow_color", Color(0,255,0))
	
func _pressed():
	print("Selected card %d", card_id)
	card_clicked.emit(card_id)
