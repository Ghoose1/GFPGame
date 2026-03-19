extends Label

func update_value(new_value : int) -> void:
	text = "$: %s" % new_value
