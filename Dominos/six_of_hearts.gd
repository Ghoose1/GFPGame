@tool
class_name SixOfHearts extends Domino

## 'top' face when in default rotation
@export var face : Face

func score_value() -> int:
	return 36
	
func score_animation() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Score")

@onready var sprites : Array[Sprite2D] = [ $Sprites/Base, $Sprites/Front ]
func rotate_sprites() -> void:
	rotate_basic_sprite(sprites[0], rotation_direction)
	rotate_basic_sprite(sprites[1], rotation_direction)
	# we dont want to flip the design
