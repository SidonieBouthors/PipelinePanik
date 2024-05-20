extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Next.grab_focus()

func _on_skip_pressed():
	global.level_number = 0
	get_tree().change_scene_to_file("res://main.tscn")

func _on_next_pressed():
	get_tree().change_scene_to_file("res://introduction_2.tscn")
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://menu.tscn")
