extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Start.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://introduction_1.tscn")
	
func _on_level_selector_pressed():
	get_tree().change_scene_to_file("res://level_selector.tscn")

func _on_exit_pressed():
	get_tree().quit()



