extends Node
class_name Commiter

@export var inputs: Array
@export var instructions: Array = []
@export var number_of_commits: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func run():
	instructions = []

	for input in inputs:
		instructions.append(input.instr)
		input.instr = null
		input.run()

	number_of_commits += instructions.filter(func(i): return i != null).size()

func clear():
	instructions = []
