@tool
class_name BasicDomino extends Domino

var face0 : int
var face1 : int

func _ready() -> void:
	$Face_0.texture = Globals.faceSprites[face0]
	$Face_1.texture = Globals.faceSprites[face1]
