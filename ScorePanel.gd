extends PanelContainer

func _ready():
	pass

func set_label(score):
	var label = get_node("Label")
	label.text = "Score: " + str(score) + " IPC"
