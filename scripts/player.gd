extends CharacterBody2D

@export var speed = 150.0
@export var jump_velocity = -500.0

@export_group("Flame Mechanics")
@export_range(0.0, 100.0) var flame_level = 100.0
@export var flame_decay_rate = 1.0
@export var flame_recharge_amount = 50.0

const MAX_FLAME_LEVEL = 100.0

var flare_cost = 25.0
var flare_big_scale = 10.0
var flare_duration = 10.0

@onready var point_light = $PointLight2D
@onready var animated_player = $AnimatedSprite2D
@onready var flame_label = $FlameLevel

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_flaring = false
var flare_timer = 0.0
var is_midgame_crossed = false
var is_animation_locked = false
var is_dead = false 
var has_key = false


func _process(delta: float) -> void:

	if is_dead: return
	flame_level -= flame_decay_rate * delta
	flame_label.text = "Flame Level: " + str(int(flame_level)) + "/" + str(MAX_FLAME_LEVEL)

func _physics_process(delta):
	if is_dead: return 
	
	if flame_level <= 0 and not is_midgame_crossed:
		die()

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("flare"):
		use_flare()

	handle_flare_timer(delta)
	update_animation(direction)
	update_light()

	move_and_slide()


func update_animation(direction):
	if is_animation_locked:
		return

	if direction > 0:
		animated_player.flip_h = false
	elif direction < 0:
		animated_player.flip_h = true

	if not is_on_floor():
		animated_player.play("jump")
	else:
		if velocity.x != 0:
			animated_player.play("run")
		else:
			animated_player.play("idle")

func handle_flare_timer(delta):
	if is_flaring:
		flare_timer -= delta
		if flare_timer <= 0:
			is_flaring = false
			print("Flare ended. Light is back to normal.")

func update_light():
	if is_flaring:
		point_light.texture_scale = flare_big_scale
		return

	var flame_percentage = flame_level / MAX_FLAME_LEVEL
	point_light.texture_scale = lerp(0.5, 4.0, flame_percentage)
	point_light.energy = lerp(0.2, 1.5, flame_percentage)

func use_flare():
	if is_flaring or flame_level < flare_cost:
		return

	is_flaring = true
	flare_timer = flare_duration
	flame_level -= flare_cost
	print("FLARE! Light is now big.")
	
	animated_player.play("flare")
	is_animation_locked = true
	
	await get_tree().create_timer(0.4).timeout
	is_animation_locked = false


func increase_flame_level():
	flame_level = min(flame_level + flame_recharge_amount, MAX_FLAME_LEVEL)
	print("Flame recharged! New level: ", flame_level)

func die():
	if is_dead:
		return 

	is_dead = true
	is_animation_locked = true 
	set_physics_process(false) 
	velocity = Vector2.ZERO 
	flame_level=100
	animated_player.play("death")
	
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
	
func collect_key():
	has_key = true
	print("Player now has the key!")
