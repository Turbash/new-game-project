extends Area2D

@onready var animated_fire=$AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	print("fire collected")
	animated_fire.play("collected")
