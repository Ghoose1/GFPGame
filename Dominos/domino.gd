@tool
## Base class for all domino tiles
@abstract
class_name Domino
extends Node2D

func _drag() -> void: pass
signal drag()
func _undrag() -> void: pass
signal undrag()
signal sig_placed()

static var rotation_num : int = 0

#region Fields

## The domino is actively being dragged around by the player 
## Player.held_domino should be self
var dragged := false
## The domino is placed on the board and can be connected to
var placed := false
## List of dominos connected to this domino
var connected_dominos : Array[Domino] = [ ]

var is_clone : bool = false

## Array of points that other dominos can connect to this one from.
var connection_points : Array[ConnectionPoint] = []
## width in tilemap tiles (1 face = 2 tiles)
@export var width : int;
## height in tilemap tiles (1 face = 2 tiles)
@export var height : int;

## Connection point to snap to
var closest_snap_point : ConnectionPoint = null
## Domino to snap to
var closest_snap_domino : Domino = null
var has_snap_point := false
## Point on this domino that we are using to connect
var connecting_point : ConnectionPoint = null

## Position that the domino should return to when it is not placed by the player
@onready var origin_position : Vector2 
@onready var origin_rotation : float 

@export var faces : Array[Face] = [ ]

#endregion

#region Properties

func _ready() -> void:
	connection_points = []
	for child in $Connections.get_children():
		connection_points.append(child as ConnectionPoint)

func get_rect() -> Rect2:
	return ($Sprites/Base as Sprite2D).get_rect()

## Current rotation as a Direction
var rotation_direction : ConnectionPoint.Direction:
	get:
		return ConnectionPoint.round_to_direction(rotation)
	set(value):
		rotation = ConnectionPoint.direction_rotations[value]

var is_horizontal : bool:
	get:
		return rotation_direction >= 2

## In da box
var boxed : bool = false:
	get: return boxed
	set(value):
		boxed = value
		if boxed: hide()
		else: show()

## In da discard
var discarded := false:
	get: return discarded
	set(value):
		discarded = value
		if discarded: hide()
		else: show()
var in_hand := false

#endregion

#region Abstract methods
# idk why but when you autocomplete a function name in the implementation, it includes the 
# comments on the next line.
# i miss c++ 😭

## Called when the domino is placed
func on_placed() -> void: pass;

## Starts the domino's scoring animation
@abstract func score_animation() -> void;

func rotate_sprites() -> void:
	pass

#endregion

#region Methods

## Get the amount of score this domino is worth
func score_value() -> int:
	return faces.reduce(func(acc : int, face : Face) -> int: return acc + face.get_score(), 0)

func score_extras() -> void:
	for face in faces:
		if face.gold:
			Globals.player.dollars += 3
	
var previous_rotation : float = 0
func _process(_delta: float) -> void:
	queue_redraw() # for debug drawing
	
	rotate_sprites()
	
	if is_clone:
		return
	
	if dragged:
		# follow the mouse and snap to other dominos 
		global_position = get_global_mouse_position()
		snap_position()
	elif not placed and !Engine.is_editor_hint():
		# return to the original position if not being dragged and not placed
		if global_position != origin_position:
			global_position = lerp(global_position, origin_position, 0.08)
			# lerping rotations is kind of a nightmare so im just doing this instead
			rotation = origin_rotation

static var face_texture := preload("res://Assets/NewFaces.png") as Texture2D
func _draw() -> void:
	if Engine.is_editor_hint():
		return
	
	if Globals.player == null or Globals.player.held_domino == null:
		if Globals.alt_mode:
			for point in connection_points:
				if not point.enabled: continue
				var num : int = point.get_connectable_face_num()
				draw_texture_rect_region(
					face_texture, 
					Rect2(point.position.rotated(0) - Vector2(7.5, 7.5), Vector2(15, 15)), 
					Rect2(Vector2.RIGHT * num * 16, Vector2.ONE * 16),
					Color(0.5, 0.5, 0.5, 0.5)
					)
				draw_rect(Rect2(point.position.rotated(0) - Vector2(7.5, 7.5), Vector2(15, 15)), Color.GRAY, false, 1, false)
			
	else:
		if placed:
			for point in connection_points:
				if not point.enabled: continue
				var flag := false
				for held_point in Globals.player.held_domino.connection_points:
					if Face.can_faces_connect(point.faces, held_point.faces):
						flag = true
				if !flag:
					continue
				draw_rect(Rect2(point.position.rotated(0) - Vector2(7.5, 7.5), Vector2(15, 15)), Color.DEEP_PINK, false, 1, false)

## Gets the tile cords that this domino is placed over
func get_tilemap_cords() -> Array[Vector2i]:
	var tilemap : TileMapLayer = Globals.board.domino_tilemap
	var out : Array[Vector2i] = []
	
	if is_horizontal:
		for i in range(0, width * height):
			@warning_ignore("integer_division")
			out.append(tilemap.local_to_map(tilemap.to_local(global_position)) + Vector2i(i / width - (height / 2), i % width - (width / 2)))
	else:
		for i in range(0, width * height):
			@warning_ignore("integer_division")
			out.append(tilemap.local_to_map(tilemap.to_local(global_position)) + Vector2i(i % width - (width / 2), i / width - (height / 2)))
	
	return out

func _unhandled_input(event: InputEvent) -> void:
	if is_clone:
		return
	
	# logic for dragging the domino
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed(): # pick up
				if !get_rect().has_point(get_local_mouse_position()) || placed:
					return
				
				if boxed or discarded:
					return
				
				dragged = true
				rotation = 0
				Globals.player.held_domino = self
				drag.emit()
				_drag()
				
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
					undrag.emit()
					_undrag()
					return
				
				# place onto board
				if has_snap_point:
					place()
				else:
					undrag.emit()
					_undrag()
		else: 
			if !event.pressed:
				return
			# rotate the domino
			if dragged and has_snap_point:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					rotation_num += 1
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					rotation_num -= 1
			elif dragged:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					rotation += PI / 2
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					rotation -= PI / 2


#endregion

#region connection logic

func get_loop_connection_points() -> Array[ConnectionPoint]:
	return connection_points

## tries to connect to other domino from a point
## 'point' is one of this domino's points
func try_connect_from_self_to_other(other : Domino, point : ConnectionPoint) -> bool:
	#var tilemap_cords := get_tilemap_cords()
	
	for other_point in other.get_loop_connection_points():
		if not other_point.enabled:
			continue
		
		#var tilemap := Globals.board.domino_tilemap
		#var other_point_cords : Vector2i = tilemap.local_to_map(tilemap.to_local(to_global(other_point.position)) + Vector2(4, 4))
		
		# check if the other point lands on us
		#if !tilemap_cords.has(other_point_cords):
			#continue
		
		if !get_rect().has_point(to_local(other.to_global(other_point.position))):
			continue
		
		if !Face.can_faces_connect(point.faces, other_point.faces):
			continue

		connect_to(other, point)
		other.connect_to(self, other_point)
		return true

	return false

## Identify extra neighbours to potentially connect to
func try_connect_extra_neighbours() -> void:
	for point in get_loop_connection_points():
		if !point.enabled:
			continue
		
		var tilemap := Globals.board.domino_tilemap
		var cords : Vector2i = tilemap.local_to_map(tilemap.to_local(to_global(point.position)) + Vector2.ONE * 4)
		if tilemap.get_cell_tile_data(cords) == null:
			continue
		
		for other : Domino in Globals.board.placed_dominoes:
			if other == self:
				continue
			assert(other.placed)
			if connected_dominos.has(other):
				continue
			
			# could instead check if the snap point collides with the domino's hitbox
			if !other.get_tilemap_cords().has(cords): 
				continue
			
			if !other.get_rect().has_point(other.to_local(to_global(point.position))):
				continue
			
			try_connect_from_self_to_other(other, point)

## Update our data to connect to another domino
func connect_to(other : Domino, connection : ConnectionPoint) -> void:
	connected_dominos.append(other)
	if connection in connection_points:
		connection.enabled = false

## Place the domino on the board 
## This needs to take care of calling connection logic for both this domino and the connecting domino
func place() -> void:
	if closest_snap_domino == null or closest_snap_point == null:
		undrag.emit()
		_undrag()
		return

	for point in connection_points: 
		point.enabled = true
	
	placed = true
	var connection_draw_node : ConnectionDrawNode = preload("res://scenes/connection_draw_node.tscn").instantiate()
	connection_draw_node.connections = connected_dominos
	add_child(connection_draw_node)

	connected_dominos.append(closest_snap_domino)
	on_placed()
	closest_snap_domino.connect_to(self, closest_snap_point)

	# extra valid touching neighbours for real loops
	try_connect_extra_neighbours()
	
	# update the tilemap underneath us
	var tilemap : TileMapLayer = Globals.board.domino_tilemap
	for vec in get_tilemap_cords():
		tilemap.set_cell(vec, 1, Vector2i.ZERO)

	has_snap_point = false
	sig_placed.emit()
	
	if connecting_point != null:
		connecting_point.enabled = false

## minimum distance to snap to a connection point
const MIN_SNAP_DIST_SQ : float = 32.0 * 32.0

## Identify the closest valid connection points to where this domino is being dragged
func snap_position() -> void:
	closest_snap_domino = null
	closest_snap_point = null
	if !has_snap_point:
		rotation_num = 0
	has_snap_point = false
	
	var other_dominos : Array[Domino] = Globals.board.placed_dominoes
	#other_dominos = Globals.board.dominoes.filter(func(d : Domino) -> bool: return d != self)
	
	var closest_distance : float = MIN_SNAP_DIST_SQ
	
	# find the closest snap point out of all the other dominoes
	for other in other_dominos:
		for point in other.connection_points:
			if not point.enabled:
				continue
			
			var pos : Vector2 = other.global_position + point.position.rotated(other.global_rotation)
			var dist : float = global_position.distance_squared_to(pos)
			
			if dist < closest_distance:
				closest_distance = dist
				closest_snap_point = point
				closest_snap_domino = other
	
	if closest_snap_domino != null:
		# actually snap to the point
		assert(closest_snap_point != null)
		
		has_snap_point = snap_to_point()


func get_valid_connection_points() -> Array[ConnectionPoint]:
	return connection_points.filter(
		func(p : ConnectionPoint) -> bool:
			return Face.can_faces_connect(p.faces, closest_snap_point.faces)
	)
 
## Move the domino to the correct position to connect to the closest snap point
## different domino shapes may need different logic to do this
func snap_to_point() -> bool:
	var valid_points := get_valid_connection_points()

	if valid_points.is_empty():
		return false
	
	connecting_point = valid_points[rotation_num % valid_points.size()]

	# rotate so that face0 'points' towards other domino
	# (remember, closest_snap_point belongs to the other domino, so the direction is reversed)
	
	# rotate to opposite direction
	rotation = ConnectionPoint.direction_rotations[ConnectionPoint.opposite_dir[closest_snap_point.direction]] - ConnectionPoint.direction_rotations[connecting_point.direction]
	
	# rotate by the amount the connecting domino is rotated
	global_rotation += closest_snap_domino.global_rotation
	
	# 'up' now points towards the other
	
	# move so that our connection point would be the same position as their connection point
	global_position = closest_snap_domino.global_position + \
		closest_snap_point.position.rotated(closest_snap_domino.global_rotation) - \
		connecting_point.position.rotated(global_rotation)
	
	const POINT_TO_FACE : int = 16
	
	## move closer to the other domino in order to fully connect
	## basically, we need to move our face to their connection point
	global_position += ConnectionPoint.direction_vecs[closest_snap_point.direction].rotated(closest_snap_domino.global_rotation) * POINT_TO_FACE

	return true

#endregion

#region static functions

static func rotate_basic_sprite(sprite : Sprite2D, direction : int) -> void:
	match direction:
		ConnectionPoint.Direction.V_UP:
			sprite.flip_h = false
			sprite.flip_v = false
		ConnectionPoint.Direction.V_DOWN:
			sprite.flip_h = true
			sprite.flip_v = true
		ConnectionPoint.Direction.H_LEFT:
			sprite.flip_h = true
			sprite.flip_v = false
		ConnectionPoint.Direction.H_RIGHT:
			sprite.flip_h = false
			sprite.flip_v = true

#endregion
