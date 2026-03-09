extends Node

var faceSprites : Array[AtlasTexture]
var faceAtlas : Texture2D = preload("res://Assets/Basic_Faces.png")

var board : Board
var player : Player

const BASIC_FACE_COUNT := 9
func _init() -> void:
	# initialize a texture array for all the basic domino faces
	faceSprites.clear()
	faceSprites.resize(BASIC_FACE_COUNT)
	
	for i in range(0, BASIC_FACE_COUNT):
		var texture := AtlasTexture.new()
		texture.atlas = faceAtlas
		texture.region = Rect2(1 + 16 * i, 1, 12, 12)
		faceSprites[i] = texture
