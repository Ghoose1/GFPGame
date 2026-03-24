class_name Board extends Node2D

var dominoes : Array[Domino]
var boxed_dominoes : Array[Domino]

var hand : Array[Domino]

@onready var special_tilemap : TileMapLayer = $SpecialTiles
@onready var domino_tilemap : TileMapLayer = $DominoTiles
@onready var box_parent := Globals.player.find_child("BoxParent")
@onready var box : DominoBox = Globals.player.find_child("BoxRect")

func _ready() -> void:
	# generate the starting set of dominoes
	create_dominoes()
	
	# initialize hand
	#hand.resize(HAND_SIZE)
	
	# box all the dominos
	for domino in dominoes:
		if domino is StarterTile:
			continue
		
		domino.boxed = true
		boxed_dominoes.append(domino)
	
	# draw dominoes to fill the hand
	for i in range(HAND_SIZE):
		add_hand_domino()
	update_hand_domino_target_positions()
	
	Globals.board = self

## draws a domino to the hand at the given index
func add_hand_domino() -> void:
	if boxed_dominoes.is_empty():
		return
	
	var domino := pop_boxed_domino()
	hand.append(domino)
	
	domino.position = box.global_position + box.get_rect().size / 2.0
	
	domino.boxed = false
	domino.in_hand = true
	
	domino.drag.connect(func() -> void: drag_domino(domino))
	domino.undrag.connect(func() -> void: undrag_domino(domino))
	domino.sig_placed.connect(func() -> void: replace_domino(domino))
	
	box.change_count(boxed_dominoes.size(), 42)

func update_hand_domino_target_positions() -> void:
	for i in range(hand.size()):
		var domino := hand[i]
		domino.origin_position = box.global_position + box.get_rect().size + (Vector2.UP * 32 + get_hand_position(i)) * 2
		domino.origin_rotation = get_hand_rotation(i) * 0.5

func drag_domino(domino : Domino) -> void:
	assert(domino.get_parent() == box_parent)
	domino.reparent(self, true)
	domino.scale = Vector2.ONE
	
func undrag_domino(domino : Domino) -> void:
	assert(domino.get_parent() == self)
	domino.reparent(box_parent, true)
	#domino.position += get_viewport_rect().size / 4 - get_viewport().get_camera_2d().position
	
	# fuck it just cheat
	domino.global_position = domino.get_global_mouse_position()
	domino.scale = Vector2.ONE
	
	if (box_parent.get_child(1) as TextureRect).get_rect().has_point(domino.position):
		discard_domino(domino)

func discard_domino(domino : Domino) -> void:
	domino.discarded = true
	replace_domino(domino)

func replace_domino(domino : Domino) -> void:
	domino.in_hand = false
	hand.remove_at(hand.find(domino))
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
	dominoes.clear()
	
	dominoes.append($Starter)
	
	for i in range(1, 7):
		for j in range(1, 7):
			var domino : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
			domino.position = Vector2(i * 32, j * 32)
			#domino.position = Globals.domino_box.get_rect().get_center()
			
			domino.face0.number = i
			domino.face1.number = j
			
			dominoes.append(domino)
			box_parent.add_child(domino)
		
		var wild : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
		wild.face0.number = i
		wild.face1.wild = true
		
		wild.position = Vector2(i * 32, 7 * 32)
		#wild.position = Globals.domino_box.get_rect().get_center()
		
		dominoes.append(wild)
		box_parent.add_child(wild)
