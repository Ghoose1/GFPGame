@tool
## Basic domino type. Two faces
class_name BasicDomino extends Domino

## 'top' face when in default rotation
@export var face0 : Face
## 'bottom' face when in default rotation
@export var face1 : Face

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
	return face0.get_score() + face1.get_score()
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

@onready var sprites : Array[Sprite2D] = [ $Sprites/Base, $Sprites/Front ]
func rotate_sprites() -> void:
	for sprite : Sprite2D in sprites:
		rotate_basic_sprite(sprite, rotation_direction)
