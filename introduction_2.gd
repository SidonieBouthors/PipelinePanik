extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Begin.grab_focus()

func _on_begin_pressed():
	global.level_number = 0
	get_tree().change_scene_to_file("res://main.tscn")
