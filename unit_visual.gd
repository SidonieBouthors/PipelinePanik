extends Area2D

var draggable = false
var is_inside_dropzone = false
var zone_ref: DropZone
var offset: Vector2
var initialPos: Vector2

func set_sprite(image):
	get_child(0).texture = image


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("left_click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true
		if Input.is_action_pressed("left_click"):
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("left_click"):
			global.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropzone and zone_ref.occupant == self:
				tween.tween_property(self, "position", zone_ref.position, 0.2).set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)


func _on_mouse_entered():
	if not global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)


func _on_mouse_exited():
	if not global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)


func _on_body_entered(zone):
	if zone.is_in_group("dropzone"):
		if zone.occupy(self):
			is_inside_dropzone = true
			zone_ref = zone


func _on_body_exited(zone):
	if zone.is_in_group("dropzone"):
		zone.unoccupy(self)
		if zone == zone_ref:
			is_inside_dropzone = false
			
