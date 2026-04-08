extends Node2D









#Returns user back to the scene



func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scene.tscn")
