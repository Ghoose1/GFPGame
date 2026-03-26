extends Sprite2D

@onready var domino : Domino = get_parent().get_parent()

func _process(_delta: float) -> void:
	frame = domino.rotation_direction
	global_rotation = 0
	queue_redraw()
