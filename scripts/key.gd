extends Area2D

func _on_body_entered(body: Node2D):

	if body.has_method("collect_key"):
		print("Player collected the key!")
		
		body.collect_key()
		
		queue_free()
