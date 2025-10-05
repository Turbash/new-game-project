extends Area2D

func _on_body_entered(body: Node2D):

	if body.has_method("collect_key"):
		

		if body.has_key:
			print("Player has the key! Door unlocked.")
			
			get_tree().change_scene_to_file("res://win_screen.tscn")
		else:
			print("The door is locked. Find the key first!")
