extends Node2D

@onready var start_button: Button = %"Start Button"

func _ready() -> void:
	start_button.grab_focus() 

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select_menu.tscn")
