## Base class for all domino tiles
class_name Domino extends Node2D

## The domino is actively being dragged around by the player 
## Player.held_domino should be self
var dragged := false
## The domino is placed on the board and can be connected to
var placed := false
## List of dominos connected to this domino
var connected_dominos : Array[Domino] = [ ]
## Array of directions that have dominos connected to them
var connected_dirs : Array[bool] = [ ]
## Number of elements to initialize connected_dirs with
static func max_connection_count() -> int: return 0

## The side of a domino.
## Includes information such as symbol displayed (number) and anything needed for
## enhancements and special effects
class Face:
	var number : int
	# e.g. var is_gold : bool

func _init() -> void:
	connected_dirs.resize(max_connection_count())
	connected_dirs.fill(false)

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
	
	# different colours for different connection sides
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

## Connection point to snap to
var closest_point : ConnectionPoint = null
## Domino to snap to
var closest_domino : Domino = null

## Update our data to connect to another domino
func connect_to(other : Domino, connection : ConnectionPoint) -> void:
	connected_dominos.append(other)
	connected_dirs[connection.direction] = true

## Place the domino on the board 
## This needs to take care of calling connection logic for both this domino and the connecting domino
func on_placed():
	connect_to(closest_domino, closest_point)
	closest_domino.connect_to(self, closest_point)
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
				
				# place onto board
				if closest_domino != null:
					on_placed()
		else: 
			# rotate the domino
			if dragged:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					rotation += PI / 4
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					rotation -= PI / 4
	
func score() -> int:
	return 0
