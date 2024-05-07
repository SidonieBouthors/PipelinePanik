extends Node
class_name Commiter

@export var inputs: Array
@export var instructions : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func run():
	for input in inputs:
		instructions.pop_front()
		instructions.append(input.instr)
		input.run()
