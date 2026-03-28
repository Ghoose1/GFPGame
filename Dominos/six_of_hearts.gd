@tool
class_name SixOfHearts
extends Domino

## 'top' face when in default rotation
@export var face : Face

func score_value() -> int:
	return 36
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

func _ready() -> void:
	super()
	_undrag()

func get_rect() -> Rect2:
	if in_hand:
		return $Sprites/Icon.get_rect()
	else:
		return super()

func _drag() -> void:
	$Sprites/Icon.hide()
	$Sprites/Base.show()
	$Sprites/Front.show()
	$Sprites/Design.show()

func _undrag() -> void:
	$Sprites/Icon.show()
	$Sprites/Base.hide()
	$Sprites/Front.hide()
	$Sprites/Design.hide()

@onready var sprites : Array[Sprite2D] = [ $Sprites/Base, $Sprites/Front ]
func rotate_sprites() -> void:
	rotate_basic_sprite(sprites[0], rotation_direction)
	rotate_basic_sprite(sprites[1], rotation_direction)
	# we dont want to flip the design
