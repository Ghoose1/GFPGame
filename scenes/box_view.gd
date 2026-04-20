extends Control

@onready var dominoes_node : Node = $Dominoes
@onready var placed_dominoes: Array[Board]

func _ready() -> void:
	hide()

func open() -> void:
	# slide onto the screen from below
	show()
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position, 0.2)
	global_position += Vector2.DOWN * 300
	

	var dominoes := Globals.board.player_dominoes
	
	
	var index := 0
	for domino : Domino in dominoes:
		# clone the domino
		var clone := domino.duplicate()
		clone.is_clone = true
		# set the transform
		clone.position = Vector2(floor(index / 7.0), index % 7) * 36
		clone.rotation = 0
		clone.show()
		# The clones are added to this node to make cleaning up easier
		dominoes_node.add_child(clone)
		index += 1
		

func close() -> void:
	# remove all the cloned children
	for child in dominoes_node.get_children():
		child.queue_free()
	# hide this menu
	hide()

#hiding placed domino 
func placed_domino():
		placed_domino().modulate.a = 0.3
