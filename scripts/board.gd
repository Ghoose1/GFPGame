class_name Board
extends Node2D

const DISCARD_CLOSED_TEXTURE: Texture2D = preload("res://Assets/Discard_Closed.tres")
const DISCARD_OPEN_TEXTURE: Texture2D = preload("res://Assets/Discard_Open.tres")

var total_dominoes : Array[Domino]
var player_dominoes : Array[Domino]


var boxed_dominoes : Array[Domino]
var placed_dominoes : Array[Domino]
var hand : Array[Domino]

@onready var special_tilemap : TileMapLayer = $SpecialTiles
@onready var domino_tilemap : TileMapLayer = $DominoTiles
@onready var box_parent : Control = Globals.player.find_child("BoxParent", true, false) as Control
@onready var box : DominoBox = Globals.player.find_child("BoxRect", true, false) as DominoBox
@onready var discard_rect : TextureRect = box_parent.get_node_or_null("Discard") as TextureRect

var discard_is_open : bool = false

func _process(_delta: float) -> void:
	update_discard_visual()

func update_discard_visual() -> void:
	if discard_rect == null:
		return

	var should_open := false

	if Globals.player != null and Globals.player.held_domino != null:
		var mouse_pos := get_viewport().get_mouse_position()
		should_open = discard_rect.get_global_rect().has_point(mouse_pos)

	if should_open == discard_is_open:
		return

	discard_is_open = should_open
	discard_rect.texture = DISCARD_OPEN_TEXTURE if discard_is_open else DISCARD_CLOSED_TEXTURE

func _ready() -> void:
	if discard_rect != null:
		discard_rect.texture = DISCARD_CLOSED_TEXTURE

	# generate the starting set of dominoes
	create_dominoes()
	create_experimental_dominoes()

	# box all the dominos
	for domino in player_dominoes:
		domino.boxed = true
		boxed_dominoes.append(domino)

	# draw dominoes to fill the hand
	for i in range(HAND_SIZE):
		add_hand_domino()
	
	var longino : Nnonimo = preload("res://Dominos/n_omino.tscn").instantiate()
	longino.face_count = 5
	spawn_in_hand(longino)

	update_hand_domino_target_positions()
	
	Globals.board = self

func create_experimental_dominoes() -> void:
	for i in range(6):
		var cornomino : Cornomino = load("res://Dominos/cornomino.tscn").instantiate()
		for face in cornomino.faces:
			face.number = randi_range(1, 6)
		total_dominoes.append(cornomino)
		player_dominoes.append(cornomino)
		box_parent.add_child(cornomino)
	
	var card : Domino = load("res://Dominos/six_of_hearts.tscn").instantiate();
	total_dominoes.append(card)
	player_dominoes.append(card)
	box_parent.add_child(card)

func spawn_in_hand(domino : Domino) -> void:
	total_dominoes.append(domino)
	player_dominoes.append(domino)
	hand.append(domino)
	box_parent.add_child(domino)
	domino.boxed = false
	domino.in_hand = true
	domino.global_position = box.global_position + box.get_rect().size / 2.0
	
	domino.drag.connect(func() -> void: drag_domino(domino))
	domino.undrag.connect(func() -> void: undrag_domino(domino))
	domino.sig_placed.connect(func() -> void: 
		placed_dominoes.append(domino)
		replace_domino(domino)
		)

## draws a domino to the hand at the given index
func add_hand_domino() -> void:
	if boxed_dominoes.is_empty():
		return
	
	var domino := pop_boxed_domino()
	hand.append(domino)
	
	domino.global_position = box.global_position + box.get_rect().size / 2.0
	
	domino.boxed = false
	domino.in_hand = true
	
	domino.drag.connect(func() -> void: drag_domino(domino))
	domino.undrag.connect(func() -> void: undrag_domino(domino))
	domino.sig_placed.connect(func() -> void: 
		placed_dominoes.append(domino)
		replace_domino(domino)
		)
	
	box.change_count(boxed_dominoes.size(), player_dominoes.size())

func update_hand_domino_target_positions() -> void:
	for i in range(hand.size()):
		var domino := hand[i]
		domino.origin_position = box.global_position + box.get_rect().size + (Vector2.UP * 32 + get_hand_position(i)) * 2
		domino.origin_rotation = get_hand_rotation(i) * 0.5

func drag_domino(domino : Domino) -> void:
	if domino.get_parent() != box_parent:
		push_warning("Dragged domino was not in BoxParent. Repairing parent before drag.")
		domino.reparent(box_parent, true)

	domino.reparent(self, true)
	domino.scale = Vector2.ONE
	
	if Input.is_action_pressed("Trash_Domino"):
		discard_domino(domino)
	
func undrag_domino(domino : Domino) -> void:
	if domino.get_parent() == self:
		domino.reparent(box_parent, true)
	elif domino.get_parent() != box_parent:
		push_warning("Undragged domino was in an unexpected parent. Repairing parent.")
		domino.reparent(box_parent, true)
	#domino.position += get_viewport_rect().size / 4 - get_viewport().get_camera_2d().position
	
	# fuck it just cheat
	domino.global_position = domino.get_global_mouse_position()
	domino.scale = Vector2.ONE
	
	if discard_rect.get_global_rect().has_point(domino.global_position):
		discard_domino(domino)

func discard_domino(domino : Domino) -> void:
	domino.discarded = true
	domino.dragged = false
	if domino == Globals.player.held_domino:
		Globals.player.held_domino = null
	replace_domino(domino)

func replace_domino(domino : Domino) -> void:
	domino.in_hand = false
	var hand_index := hand.find(domino)
	if hand_index != -1:
		hand.remove_at(hand_index)
	if !boxed_dominoes.is_empty():
		add_hand_domino()
	update_hand_domino_target_positions()

const HAND_SIZE := 5
const HAND_GAP_RADIANS := PI / 6
static func get_hand_position(index : int) -> Vector2:
	return Vector2.UP.rotated(get_hand_rotation(index)) * 48

static func get_hand_rotation(index : int) -> float:
	return (index - ((HAND_SIZE - 1) / 2.0)) * HAND_GAP_RADIANS

func pop_boxed_domino() -> Domino:
	var index := randi_range(0, boxed_dominoes.size() - 1)
	var domino := boxed_dominoes[index]
	boxed_dominoes.remove_at(index)
	return domino 

func create_dominoes() -> void:
	total_dominoes.clear()
	
	total_dominoes.append($Starter)
	placed_dominoes.append($Starter)
	
	for i in range(1, 7):
		for j in range(1, 7):
			var domino : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
			domino.position = Vector2(i * 32, j * 32)
			#domino.position = Globals.domino_box.get_rect().get_center()
			
			domino.faces[0].number = i
			domino.faces[1].number = j
			
			total_dominoes.append(domino)
			player_dominoes.append(domino)
			box_parent.add_child(domino)
		
		var wild : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
		wild.faces[0].number = i
		wild.faces[1].wild = true
		
		wild.position = Vector2(i * 32, 7 * 32)
		#wild.position = Globals.domino_box.get_rect().get_center()
		
		total_dominoes.append(wild)
		player_dominoes.append(wild)
		box_parent.add_child(wild)
		
