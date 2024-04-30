extends PanelContainer

const instruction = preload("res://instruction_panel.tscn")

func populate(instruction_list):
	for instruction_node in instruction_list:
		print("POPULATING")
		var ins = instruction.instantiate()
		ins.set_label(instruction_node.get_text())
		ins.visible = true
		$InstructionsContainer.add_child(ins)
