extends Node2D


#Options Menu (Music Volume, Fullscreen/Windowed)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
