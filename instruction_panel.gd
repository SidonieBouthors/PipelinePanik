extends PanelContainer

func _ready():
	visible = false

func set_label(text):
	var label = get_node("Label")
	label.text = text
