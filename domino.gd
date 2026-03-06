class_name Domino extends Node2D

var position_locked := false
var dragged := false

class Face:
	var number : int

func _process(delta: float) -> void:
	if dragged:
		global_position = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if !$Base.get_rect().has_point(to_local(event.position)):
					return
				
				dragged = true
				get_viewport().set_input_as_handled()
			else:
				dragged = false
			
