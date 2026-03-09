
static var faceSprites : Array[AtlasTexture]
static var faceAtlas : Texture2D = preload("res://Assets/Basic_Faces.png")

const BASIC_FACE_COUNT := 9
static func _static_init() -> void:
	faceSprites.clear()
	faceSprites.resize(BASIC_FACE_COUNT)
	
	for i in range(0, BASIC_FACE_COUNT):
		var texture := AtlasTexture.new()
		texture.atlas = faceAtlas
		texture.region = Rect2(1 + 16 * i, 1, 12, 12)
		faceSprites[i] = texture
