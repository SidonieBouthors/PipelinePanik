extends PanelContainer

const instruction = preload ("res://instruction_panel.tscn")
var instruction_children = []

func _ready():
	pass

func populate(instruction_list):
	for instruction_node in instruction_list:
		var ins = instruction.instantiate()
		ins.set_label(instruction_node.get_text())
		ins.visible = true
		$InstructionsContainer.add_child(ins)
		instruction_children.append(ins)
		
func repopulate(instruction_list):
	empty()
	populate(instruction_list)
	
func empty():
	for child in instruction_children:
		$InstructionsContainer.remove_child(child)
	instruction_children = []
