extends CharacterBody2D

@export var speed = 150.0
@export var jump_velocity = -300.0

@export_range(0.0, 100.0) var flame_level = 100.0
const MAX_FLAME_LEVEL = 100.0
@export var flame_decay_rate = 1.0

var flare_cost = 25.0
var flare_big_scale = 10.0 
var flare_duration = 10

@onready var point_light = $PointLight2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_flaring = false 
var flare_timer = 0.0 

func _physics_process(delta):
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

	if is_flaring:
		flare_timer -= delta
		if flare_timer <= 0:
			is_flaring = false
			print("Flare ended. Light is back to normal.")

	flame_level = max(0, flame_level - flame_decay_rate * delta)
	update_light()

	move_and_slide()

func update_light():
	if is_flaring:
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
	point_light.texture_scale = flare_big_scale
	print("FLARE! Light is now big.")
