extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Next.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_skip_pressed():
	get_tree().change_scene_to_file("res://main.tscn")


func _on_next_pressed():
	pass # Replace with function body.
