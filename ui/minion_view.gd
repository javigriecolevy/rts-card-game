extends Button
class_name MinionView

@export var card_view: CardView
@export var VFXLayer: Control
@export var AttackGlow: TextureRect
@export var TargettedGlow: TextureRect
@export var attack_timer: CircularTimer
@export var enchantments_container: HBoxContainer


signal minion_clicked(minion_id)

var entity_id: int
var enchants_with_timers: Array[Enchantment]
var enchantment_timers: Array[CircularTimer]
var CircularTimerScene = preload("res://scenes/ui_scenes/circular_timer.tscn")

func setup(minion: Minion):
	AttackGlow.material = AttackGlow.material.duplicate()
	TargettedGlow.material = TargettedGlow.material.duplicate()
	entity_id = minion.id
	card_view.setup(minion.card)
	card_view.minion_setup()
	update_stats(minion)
	for enchantment in minion.enchantments:
		add_enchantment_timer()

func update_stats(minion: Minion):
	card_view.HealthLabel.text = str(minion.health)
	card_view.AttackLabel.text = str(minion.attack)
	#TODO: Change Label color if the stat is higher or lower than on the minion.card

func update_can_attack_view(enabled: bool):
	if enabled:
		AttackGlow.material.set_shader_parameter("glow_strength", 10.0)
	else:
		AttackGlow.material.set_shader_parameter("glow_strength", 0.0)

func is_selected(enabled: bool):
	if enabled:
		AttackGlow.material.set_shader_parameter("pulse_speed", 5.5)
		AttackGlow.material.set_shader_parameter("glow_color", Color.ORANGE)
	else:
		AttackGlow.material.set_shader_parameter("pulse_speed", 0.0)
		AttackGlow.material.set_shader_parameter("glow_color", Color(0,255,0))

func is_target(enabled: bool):
	if enabled:
		TargettedGlow.material.set_shader_parameter("glow_strength", 5.5)
	else:
		TargettedGlow.material.set_shader_parameter("glow_strength", 0.0)

func update_timers(tick: int, minion: Minion):
	update_attack_timer(tick, minion)
	update_enchantments_timers(tick, minion)

func update_enchantments_timers(tick: int, minion: Minion):
	for i in range(enchantments_container.get_child_count() - 1, -1, -1):
		if i <  minion.enchantments.size():
			var enchantment = minion.enchantments[i]
			if enchantment.expires_at_tick:
				var timer = enchantments_container.get_child(i)
				var remaining = enchantment.expires_at_tick - tick
				var duration = enchantment.expires_at_tick - enchantment.applied_at_tick
				var progress = 1.0 - float(remaining) / duration
				timer.set_progress(progress)
				if remaining <= 1:
					enchantments_container.get_child(i).queue_free()
					print("REMOVED TIMER ENCHANTMENT")

func update_attack_timer(tick: int, minion: Minion):
	if minion.ready_at_tick <= tick:
		attack_timer.visible = false
		return
	attack_timer.visible = true
	var remaining = minion.ready_at_tick - tick
	var progress = 1.0 - float(remaining) / minion.attack_cooldown
	attack_timer.set_progress(progress)

func add_enchantment_timer():
	print("adding timer enchantment!")
	var new_timer: CircularTimer = CircularTimerScene.instantiate()
	new_timer.visible = true
	enchantments_container.add_child(new_timer)
	print("enchantment child count: ",enchantments_container.get_child_count())

func _pressed():
	minion_clicked.emit(entity_id)
