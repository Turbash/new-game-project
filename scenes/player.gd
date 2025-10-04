extends CharacterBody2D

@export var speed = 150.0
@export var jump_velocity = -300.0

@export_range(0.0, 100.0) var flame_level = 100.0
const MAX_FLAME_LEVEL = 100.0
@export var flame_decay_rate = 1.0

var flare_cost = 25.0
var flare_scale_multiplier = 3.0
var flare_duration = 0.8 

@onready var player_sprite = $Player
@onready var point_light = $PointLight2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	flame_level = max(0, flame_level - flame_decay_rate * delta)
	update_light()

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("flare"):
		use_flare()

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func update_light():
	var flame_percentage = flame_level / MAX_FLAME_LEVEL
	point_light.texture_scale = lerp(0.5, 4.0, flame_percentage)
	point_light.energy = lerp(0.2, 1.5, flame_percentage)

func use_flare():
	if flame_level < flare_cost:
		return 

	if get_tree().get_first_node_in_group("tweens") and get_tree().get_first_node_in_group("tweens").is_running():
		return

	flame_level -= flare_cost
	print("Used Flare! Current flame: ", flame_level)

	var original_scale = point_light.texture_scale
	var flare_scale = original_scale * flare_scale_multiplier

	var tween = create_tween()
	tween.add_to_group("tweens")

	tween.tween_property(point_light, "texture_scale", flare_scale, flare_duration * 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(point_light, "texture_scale", original_scale, flare_duration * 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
