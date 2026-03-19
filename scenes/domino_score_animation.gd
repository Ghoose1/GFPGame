class_name DominoScoreAnimation extends Node2D

static var sync_started_ms : int = 0
static var cleanup_at_ms : int = -1
const FPS : float = 8.0

var tile_id : int = -1
var current_anim : StringName = &"startblock"

func setup_for_tile(tile : Domino) -> void:
	tile_id = tile.get_instance_id()
	position = tile.position
	add_to_group("domino_score_animation")
	set_visual_for_tile(tile)

func set_visual_for_tile(tile : Domino) -> void:
	if tile is StarterTile:
		set_animation(&"startblock")
	elif tile.is_horizontal:
		set_animation(&"horizontal")
	else:
		set_animation(&"vertical")

func set_animation(anim : StringName) -> void:
	current_anim = anim
	var sprite : AnimatedSprite2D = $AnimatedSprite2D
	sprite.animation = anim
	sync_frame()

func _process(_delta : float) -> void:
	if cleanup_at_ms > 0 and Time.get_ticks_msec() >= cleanup_at_ms:
		queue_free()
		return

	if sync_started_ms > 0:
		sync_frame()

func sync_frame() -> void:
	var sprite : AnimatedSprite2D = $AnimatedSprite2D
	var frames : SpriteFrames = sprite.sprite_frames
	if frames == null:
		return

	var frame_count : int = frames.get_frame_count(current_anim)
	if frame_count <= 0:
		return

	var elapsed : float = (Time.get_ticks_msec() - sync_started_ms) / 1000.0
	var total_frames : int = int(floor(elapsed * FPS))

	sprite.frame = total_frames % frame_count
	sprite.frame_progress = fmod(elapsed * FPS, 1.0)
