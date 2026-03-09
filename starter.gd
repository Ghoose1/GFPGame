class_name StarterTile extends Domino

var face : int

func _ready() -> void:
	face = randi_range(0, 6)
	$Face_0.texture = Globals.faceSprites[face]
