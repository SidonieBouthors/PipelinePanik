extends Node
class_name ROB

@export var inputs: Array = []
@export var outputs: Array = []
@export var semaphore : int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func commit():
	pass

# Can be called multiple times per clock cycle (if multiple outputs)
func run():
	semaphore -= 1

	# If all outputs are done, run the ROB
	if semaphore == 0:
		commit()

		for unit in inputs:
			unit.run()
