class_name Board extends Node2D

var dominoes : Array[Domino]
var boxed_dominoes : Array[Domino]

var hand : Array[Domino]

@onready var special_tilemap : TileMapLayer = $SpecialTiles
@onready var domino_tilemap : TileMapLayer = $DominoTiles
@onready var box : DominoBox = $CanvasLayer/Control/BoxRect
@onready var layer : CanvasLayer = $CanvasLayer

func _ready() -> void:
	create_dominoes()
	
	# box all the dominos
	for domino in dominoes:
		if domino is StarterTile:
			continue
		
		domino.boxed = true
		boxed_dominoes.append(domino)
	
	for i in range(HAND_SIZE):
		var domino := pop_boxed_domino()
		domino.position = Globals.domino_box.get_rect().get_center() + Vector2.UP * 32 + get_hand_position(i)
		domino.rotation = get_hand_rotation(i) * 0.5
		
		domino.origin_rotation = domino.rotation
		domino.origin_position = domino.position
		
		domino.boxed = false
		domino.in_hand = true
		
		domino.drag.connect(func() -> void: drag_domino(domino))
		domino.undrag.connect(func() -> void: undrag_domino(domino))
		
		hand.append(domino)
	
	Globals.board = self

func drag_domino(domino : Domino) -> void:
	assert(domino.get_parent() == layer)
	domino.reparent(self)
	print("dragged")
	
	#domino.undrag.disconnect(undrag_domino)
	#domino.drag.disconnect(drag_domino)
	
func undrag_domino(domino : Domino) -> void:
	assert(domino.get_parent() == self)
	domino.reparent(layer)
	print("undragged")
	
	#domino.undrag.disconnect(undrag_domino)
	#domino.drag.disconnect(drag_domino)

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
			$CanvasLayer.add_child(domino)
		
		var wild : BasicDomino = preload("res://Dominos/basic.tscn").instantiate()
		wild.face0.number = i
		wild.face1.wild = true
		
		wild.position = Vector2(i * 32, 7 * 32)
		#wild.position = Globals.domino_box.get_rect().get_center()
		
		dominoes.append(wild)
		$CanvasLayer.add_child(wild)
