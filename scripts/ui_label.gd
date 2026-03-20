extends Label

@export var score_text : String = ""

func update_value(new_value : int) -> void:
	text = score_text + str(new_value)
