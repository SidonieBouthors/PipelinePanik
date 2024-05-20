extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Level0.grab_focus()




func _on_level_0_pressed():
	global.level_number = 0
	get_tree().change_scene_to_file("res://main.tscn")
	

func _on_level_1_pressed():
	global.level_number = 1
	get_tree().change_scene_to_file("res://main.tscn")


func _on_level_2_pressed():
	global.level_number = 2
	get_tree().change_scene_to_file("res://main.tscn")


func _on_return_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")	
