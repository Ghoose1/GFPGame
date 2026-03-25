extends Camera2D

const CAMERA_SPEED := 480
const MIN_ZOOM := 0.5
const MAX_ZOOM := 4.0

@onready var origin_position := position
@onready var origin_zoom := zoom

func _process(delta: float) -> void:
	if Input.is_action_pressed("Camera_Down"):
		position += Vector2.DOWN * delta * CAMERA_SPEED / zoom.x
	if Input.is_action_pressed("Camera_Up"):
		position += Vector2.UP * delta * CAMERA_SPEED / zoom.x
	if Input.is_action_pressed("Camera_Left"):
		position += Vector2.LEFT * delta * CAMERA_SPEED / zoom.x
	if Input.is_action_pressed("Camera_Right"):
		position += Vector2.RIGHT * delta * CAMERA_SPEED / zoom.x
	if Input.is_action_pressed("Camera_Reset"):
		position = origin_position
		zoom = origin_zoom

func _unhandled_input(event : InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom *= 1 + (0.1)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom /= 1 + (0.1)

	zoom.x = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
	zoom.y = clamp(zoom.y, MIN_ZOOM, MAX_ZOOM)
