extends Node2D

@onready var start_button: Button = %"Start Button"

func _enter_tree() -> void:
	Globals.is_level_previous = false
	Globals.current_level_scene = null #does this correctly free the memery>?

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
