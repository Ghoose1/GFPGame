class_name DominoBox extends TextureRect

func _ready() -> void:
	Globals.domino_box = self

@onready var label : Label = $Label

func change_count(current : int, total : int) -> void:
	label.text = str(current) + "/" + str(total)
