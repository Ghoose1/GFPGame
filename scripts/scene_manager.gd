extends Node
 
var previous_scenes : Array[Node] = [ ] 

func switch_to_scene(new_scene : Node, push_previous : bool) -> void:
	if push_previous:
		previous_scenes.push_back(get_tree().current_scene)
	
	var tree := get_tree()
	Globals.current_level_scene = tree.current_scene
	tree.root.remove_child(Globals.current_level_scene)
	tree.root.add_child(new_scene)
	tree.set_current_scene(new_scene)
	print("let me put a breakpoint here")

func switch_to_previous() -> void:
	assert(previous_scenes.size() > 0)
	var tree := get_tree()
	
	var previous = previous_scenes.back()
	previous_scenes.pop_back()
	
	tree.get_current_scene().queue_free()
	tree.root.add_child(previous)
	tree.set_current_scene(previous)
