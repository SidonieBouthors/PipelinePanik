extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Begin.grab_focus()

func _on_begin_pressed():
	global.level_number = 0
	get_tree().change_scene_to_file("res://main.tscn")
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://menu.tscn")
