@tool
class_name ScoreLabel extends Label

@export var score_text : String = ""

func _ready() -> void:
	text = score_text

func update_value(new_value : Variant) -> void:
	text = score_text + str(new_value)
