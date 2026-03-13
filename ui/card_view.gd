extends Control
class_name CardView

@export var CostLabel : Label
@export var HealthLabel : Label
@export var AttackLabel : Label
@export var DisplayNameLabel : Label
@export var DescriptionLabel : Label

@export var CardBorder : TextureRect
@export var Shadow : TextureRect
@export var CardArt : TextureRect
@export var TextGradient : TextureRect

func setup(definition: CardInfo):

	CostLabel.text = str(definition.cost)
	DisplayNameLabel.text = str(definition.display_name)
	HealthLabel.text = str(definition.health)
	AttackLabel.text = str(definition.attack)
	
	Shadow.visible = true
	CardBorder.texture = load("res://assets/card_assets/card_border.png")
	
	DescriptionLabel.text = definition.description
	if not definition.description:
		TextGradient.visible = false
	
	var art_path = "res://assets/card_assets/card_art/%s.png" % definition.id
	if ResourceLoader.exists(art_path):
		CardArt.texture = load(art_path)
	HealthLabel.add_theme_color_override("font_color", Color(1, 0, 0))
	
func minion_setup():
	Shadow.visible = false
	CostLabel.visible = false
	CardBorder.texture = load("res://assets/card_assets/minion_border.png")
	HealthLabel.add_theme_color_override("font_color", Color(1, 0, 0))
