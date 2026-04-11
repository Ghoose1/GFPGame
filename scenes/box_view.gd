extends Control

#Returns user back to the scene
#func _on_exit_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/scene.tscn")

@onready var dominoes_node : Node = $Dominoes

func _ready() -> void:
	hide()

func open() -> void:
	show()
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position, 0.2)
	global_position += Vector2.DOWN * 300

	var dominoes := Globals.board.player_dominoes
	
	var index := 0
	for domino : Domino in dominoes:
		var clone := domino.duplicate()
		clone.is_clone = true
		clone.position = Vector2(floor(index / 7.0), index % 7) * 36
		clone.rotation = 0
		clone.show()
		dominoes_node.add_child(clone)
		index += 1
		#clone.position = Vector2(floor(index / 7.0), index % 7) * 24

func close() -> void:
	for child in dominoes_node.get_children():
		child.queue_free()
	hide()
