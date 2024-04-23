extends StaticBody2D
class_name DropZone

var occupied = false
var occupant

const color = Color.AQUAMARINE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.is_dragging:
		visible = true
		if occupied:
			modulate = Color(color, 1)
		else:
			modulate = Color(color, 0.7)
	else:
		visible = false

func occupy(object) -> bool:
	if not occupied:
		occupied = true
		occupant = object
		return true
	else:
		return false
		
func unoccupy(object):
	if occupant == object:
		occupied = false
		occupant = null
