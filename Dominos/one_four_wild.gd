@tool
class_name OneFourWild
extends Domino

@export var faces : Array[Face]

var loop_connections : Array[ConnectionPoint]

func _ready() -> void:
	super()
	loop_connections.append_array(connection_points)
	for child in $LoopConnections.get_children():
		child.enabled = true
		loop_connections.append(child as ConnectionPoint)

func get_loop_connection_points() -> Array[ConnectionPoint]:
	return loop_connections

func score_value() -> int:
	var total := 0
	for face : Face in faces:
		total += face.get_score()
	return total

func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

@onready var sprites : Array[Sprite2D] = [ $Sprites/Base, $Sprites/Front ]
func rotate_sprites() -> void:
	for sprite : Sprite2D in sprites:
		rotate_basic_sprite(sprite, rotation_direction)
