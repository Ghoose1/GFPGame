class_name ConnectionDrawNode extends Node2D

var connections : Array[Domino];
var timer : float = DRAW_CONNECTION_MAX_TIME
const DRAW_CONNECTION_MAX_TIME := 0.1

func _process(delta: float) -> void:
	print(timer)
	if timer > 0:
		timer -= delta
		queue_redraw()
	else:
		queue_free()

func get_width(x : float) -> float: 
	return x if x < 0.75 else 3 - 3 * x
func _draw() -> void:
	for domino in connections:
		draw_line(Vector2.ZERO, to_local(domino.global_position), 
		Color.LIME_GREEN, 
		2.0 * get_width(float(DRAW_CONNECTION_MAX_TIME - timer) / DRAW_CONNECTION_MAX_TIME), 
		false)
	
