extends Area2D

@onready var animated_fire = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("increase_flame_level"):
		
		body.increase_flame_level()
		
		print("Fire collected by player.")
		
		collision_shape.set_deferred("disabled", true)

		animated_fire.play("collected")

		await animated_fire.animation_finished
		
		queue_free()
