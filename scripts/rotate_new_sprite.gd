extends Sprite2D

@onready var domino : Domino = get_parent().get_parent()

func _process(_delta: float) -> void:
	match domino.rotation_direction:
		ConnectionPoint.Direction.V_UP:
			flip_h = false
			flip_v = false
		ConnectionPoint.Direction.V_DOWN:
			flip_h = true
			flip_v = true
		ConnectionPoint.Direction.H_LEFT:
			flip_h = true
			flip_v = false
		ConnectionPoint.Direction.H_RIGHT:
			flip_h = false
			flip_v = true
	queue_redraw()
