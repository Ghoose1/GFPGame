## Base class for all domino tiles
@abstract class_name Domino extends Node2D

#region Fields

## The domino is actively being dragged around by the player 
## Player.held_domino should be self
var dragged := false
## The domino is placed on the board and can be connected to
var placed := false
## List of dominos connected to this domino
var connected_dominos : Array[Domino] = [ ]
## Array of points that other dominos can connect to this one from.
var connection_points : Array[ConnectionPoint]

## Connection point to snap to
var closest_point : ConnectionPoint = null
## Domino to snap to
var closest_domino : Domino = null

## Position that the domino should return to when it is not placed by the player
@onready var origin_position : Vector2 = global_position
@onready var origin_rotation : float = rotation

#endregion

#region Properties

## Current rotation as a Direction
var rotation_direction : ConnectionPoint.Direction:
	get:
		return ConnectionPoint.round_to_direction(rotation)
	set(value):
		rotation = ConnectionPoint.direction_rotations[rotation_direction]

var is_horizontal : bool:
	get:
		return rotation_direction >= 2

#endregion

#region Abstract methods
# idk why but when you autocomplete a function name in the implementation, it includes the 
# comments on the next line.
# i miss c++ 😭

## width in tilemap tiles (1 face = 2 tiles)
@abstract func get_width() -> int
## height in tilemap tiles (1 face = 2 tiles)
@abstract func get_height() -> int
@abstract func init_connection_points() -> void

# different domino types will need to implement their own logic for how to snap to positions
## Snap this domino to the nearest other domino they can connect to.
## Set closest_point and closest_domino to correct values
@abstract func snap_position() -> void


## Get the amount of score this domino is worth
@abstract func score_value() -> int
## Starts the domino's scoring animation
@abstract func score_animation() -> void

#endregion

#region Methods

func _init() -> void:
	init_connection_points()

func _process(_delta: float) -> void:
	queue_redraw() # for debug drawing
	
	if dragged:
		# follow the mouse and snap to other dominos 
		global_position = get_global_mouse_position()
		snap_position()
	elif not placed:
		# return to the original position if not being dragged and not placed
		if global_position != origin_position:
			global_position = lerp(global_position, origin_position, 0.08)
			# lerping rotations is kind of a nightmare so im just doing this instead
			rotation = origin_rotation

func _draw() -> void:
	# draw a quick preview of where the connection points are
	if Engine.is_editor_hint():
		return
	
	if dragged:
		return
	
	if Globals.player.held_domino == null:
		return
	
	# different colours for different connection sides
	const colours := [ Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW ]
	for point in connection_points:
		if not point.enabled: continue
		draw_rect(Rect2(point.position.rotated(0) - Vector2(7, 7), Vector2(14, 14)), colours[point.direction], false, 1, false)

## Gets the tile cords that this domino is placed over
func get_tilemap_cords() -> Array[Vector2i]:
	var tilemap : TileMapLayer = Globals.board.domino_tilemap
	var out : Array[Vector2i] = []
	
	var width := get_width()
	var height := get_height()
	
	if is_horizontal:
		for i in range(0, width * height):
			@warning_ignore("integer_division")
			out.append(tilemap.local_to_map(tilemap.to_local(global_position)) + Vector2i(i / width - (height / 2), i % width - (width / 2)))
	else:
		for i in range(0, width * height):
			@warning_ignore("integer_division")
			out.append(tilemap.local_to_map(tilemap.to_local(global_position)) + Vector2i(i % width - (width / 2), i / width - (height / 2)))
	
	return out

## Update our data to connect to another domino
func connect_to(other : Domino, connection : ConnectionPoint) -> void:
	connected_dominos.append(other)
	connection_points[connection.direction].enabled = false

## Place the domino on the board 
## This needs to take care of calling connection logic for both this domino and the connecting domino
func on_placed() -> void:
	for point in connection_points: 
		point.enabled = true
	connect_to(closest_domino, closest_point)
	closest_domino.connect_to(self, closest_point)
	placed = true

func _unhandled_input(event: InputEvent) -> void:
	# logic for dragging the domino
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed(): # pick up
				if !$Sprites/Base.get_rect().has_point(get_local_mouse_position()) || placed:
					return
				
				dragged = true
				Globals.player.held_domino = self
				get_viewport().set_input_as_handled()
			elif event.is_released() and dragged: # put down
				dragged = false
				Globals.player.held_domino = null
				
				# check if each of the tiles this domino would be placed on is occupied by another tile
				var placeCords := get_tilemap_cords()
				var tilesOccupied := false
				var domino_tilemap : TileMapLayer = Globals.board.domino_tilemap
				var special_tilemap : TileMapLayer = Globals.board.special_tilemap
				
				for vec in placeCords:
					var domino_data := domino_tilemap.get_cell_tile_data(vec)
					var special_data := special_tilemap.get_cell_tile_data(vec)
					if domino_data != null or (special_data != null and special_data.get_custom_data("is_obstacle")):
						tilesOccupied = true
						break
				
				if tilesOccupied:
					return
				
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

#endregion
