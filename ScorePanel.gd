extends PanelContainer

func _ready():
	pass

func set_label(score):
	var label = get_child(0).get_child(0)
		
	label.text = "Score: " + str(snapped(score, 0.01)) + " IPC"
