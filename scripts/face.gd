
## The side of a domino.
## Includes information such as symbol displayed (number) and anything needed for
## enhancements and special effects
class_name Face 

var number : int
# e.g. var is_gold : bool

func can_connect_to(faces : Array[Face]) -> bool:
	return faces.all(func(f : Face) -> bool: return f.number == number)

static func can_faces_connect(a : Array[Face], b : Array[Face]) -> bool:
	match a.size():
		0:
			return false
		1:
			return a[0].can_connect_to(b)
	
	match b.size():
		0: 
			return false
		1:
			return b[0].can_connect_to(a)
	
	return false
