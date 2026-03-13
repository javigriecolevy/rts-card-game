extends Button
class_name HeroView

@export var hero_power_button: Node

@export var VFXLayer: Control
@export var AttackGlow: TextureRect
@export var TargettedGlow: TextureRect

@export var HealthLabel : Label
@export var ArmorLabel : Label
@export var AttackLabel : Label
@export var ArmorBG : TextureRect
@export var AttackBG : TextureRect

@export var HeroArt : TextureRect

var entity_id: int

signal hero_clicked(hero_id)
signal hero_power_clicked(hero_id)

func _ready() -> void:
	hero_power_button.pressed.connect(_on_hero_power_clicked)

func setup(hero: Hero):
	TargettedGlow.material = TargettedGlow.material.duplicate()
	entity_id = hero.id
	
	var art_path = "res://assets/hero_assets/hero_art/%s.png" % hero.card.id
	if ResourceLoader.exists(art_path):
		HeroArt.texture = load(art_path)
	update_stats(hero)

func update_stats(hero: Hero):
	HealthLabel.text = str(hero.health)
	
	if hero.attack > 0:
		AttackLabel.text = str(hero.attack)
		AttackBG.visible = true
	else:
		AttackLabel.text = str("")
		AttackBG.visible = false
	
	if hero.armor > 0:
		ArmorLabel.text = str(hero.armor)
		ArmorBG.visible = true
	else:
		ArmorLabel.text = str("")
		ArmorBG.visible = false

func is_target(enabled: bool):
	if enabled:
		TargettedGlow.material.set_shader_parameter("glow_strength", 10)
	else:
		TargettedGlow.material.set_shader_parameter("glow_strength", 0.0)

func _pressed():
	hero_clicked.emit(entity_id)

func _on_hero_power_clicked():
	hero_power_clicked.emit(entity_id)
