extends PanelContainer

func _ready():
	pass

func set_label(text):
	print(text)
	var label = get_node("Label")
	label.text = text
