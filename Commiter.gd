extends Node
class_name Commiter

@export var inputs: Array
@export var instructions : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func run():
	for input in inputs:
		instructions.pop_at(0)
		instructions.append(input.instr)
		input.run()
