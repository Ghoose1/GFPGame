class_name Domino extends Node2D

var position_locked := false
var dragged := false
var placed := false
var connected_dominos : Array[Domino] = [ null, null, null, null ]

const SNAP_POINTS := 4

# The side of a domino.
# Includes information such as symbol displayed (number) and anything needed for
# enhancements and special effects
class Face:
	var number : int
	# e.g. var is_gold : bool

func _process(_delta: float) -> void:
	queue_redraw() # for debug drawing
	
	if dragged:
		# follow the mouse and snap to other dominos 
		global_position = get_global_mouse_position()
		snap_position()

func _draw() -> void:
	# draw a quick preview of where the connection points are
	if dragged:
		return
	
	var held_domino = Globals.player.held_domino
	if held_domino == null:
		return
	
	const colours := [ Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW ]
	for point in get_connection_points():
		draw_rect(Rect2(point.position.rotated(0) - Vector2(7, 7), Vector2(14, 14)), colours[point.direction], false, 1, false)

# different domino types will need to implement their own logic for how to snap to positions
## Snap this domino to the nearest other domino they can connect to
func snap_position() -> void:
	pass

## Array of points that other dominos can connect to this one from.
func get_connection_points() -> Array[ConnectionPoint]:
	return []

var closest_point : ConnectionPoint = null
var closest_domino : Domino = null

func connect_to_other(other : Domino):
	connected_dominos[ConnectionPoint.opposite_dir[closest_point.direction]] = other
	other.connected_dominos[closest_point.direction] = self
	placed = true

func _unhandled_input(event: InputEvent) -> void:
	# logic for dragging the domino
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: # pick up
				if !$Base.get_rect().has_point(get_local_mouse_position()) || placed:
					return
				
				dragged = true
				Globals.player.held_domino = self
				get_viewport().set_input_as_handled()
			else: # put down
				dragged = false
				Globals.player.held_domino = null
				
				# connect
				if closest_domino != null:
					connect_to_other(closest_domino)
		else: 
			# rotate the domino
			if dragged:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					rotation += PI / 4
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					rotation -= PI / 4
	
