class_name Domino extends Node2D

var position_locked := false
var dragged := false

const SNAP_POINTS := 4

class Face:
	var number : int

func _process(delta: float) -> void:
	if dragged:
		global_position = get_global_mouse_position()
		snap_position()
		queue_redraw()

var closest_point : Vector2
var closest_other_point : Vector2
func snap_position() -> void:
	var other_dominos : Array[Domino] = []
	var board : Board = get_parent()
	other_dominos = board.dominoes.filter(func(d : Domino): return d != self)
	
	var closest_point_dist : float = 99999
	var closest_domino : Domino
	for i in range(0, SNAP_POINTS):
		var point = get_snap_points()[i] + global_position
		var other : Domino = other_dominos.reduce(closest_to_pos(point), other_dominos[0])
		var other_snap_points = other.get_snap_points().map(func(v): return v + other.global_position)
		var close_point = other_snap_points.reduce(closest_to_pos_vec(point), Vector2(99999, 99999))
		var dist = point.distance_squared_to(close_point)
		if dist < closest_point_dist:
			closest_domino = other
			closest_point_dist = dist
			closest_point = point
			closest_other_point = close_point 
	
	const SNAP_MIN_DIST := 32 * 32
	if closest_point_dist < SNAP_MIN_DIST:
		global_position = closest_other_point - closest_point + global_position

func closest_to_pos(target : Vector2):
	return func(a, b): 
		return a if a.global_position.distance_squared_to(target) < b.global_position.distance_squared_to(target) else b
func closest_to_pos_vec(target : Vector2):
	return func(a : Vector2, b : Vector2): 
		return a if a.distance_squared_to(target) < b.distance_squared_to(target) else b

func get_snap_points() -> Array[Vector2]:
	return [ Vector2(0, 15), Vector2(0, -15), Vector2(-8, 0), Vector2(8, 0) ]

func _draw() -> void:
	if dragged:
		draw_line(closest_point - global_position, closest_other_point - global_position, Color.PURPLE, 2)
	for point in get_snap_points():
		draw_circle(point, 2, Color.PINK)

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if !$Base.get_rect().has_point(to_local(event.position)):
					return
				
				dragged = true
				get_viewport().set_input_as_handled()
			else:
				dragged = false
		else: 
			if dragged:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					rotation += PI / 4
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					rotation -= PI / 4
	
