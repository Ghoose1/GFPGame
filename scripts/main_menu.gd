extends Node2D

@onready var start_button: Button = %"Start Button"

func _ready() -> void:
	start_button.grab_focus() 

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select_menu.tscn")

func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options.tscn")
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
