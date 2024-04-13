extends Node
class_name Scheduler

var inputs : Array[Unit]
var outputs : Array[Unit]
var semaphore : int

var available_inputs : Array[Unit] = []
var available_outputs : Array[Unit] = []

func scheduler():
	update_available()
	for input in available_inputs:
		for output in outputs:
			if check_type(input, output):
				if not is_dependent(input, output):
					pass
				
func schedule(old: Unit, new: Unit):
	pass
	

func update_available():
	available_inputs = inputs.filter(func(unit): return unit.instr.type != Instruction.Type.NOP)
	
func update_stall():
	pass

func check_type(unit1 : Unit, unit2: Unit):
	return unit1.instr.type == unit2.instr.type
	
func is_dependent(input: Unit, output: Unit):
	return not (input.instr.inputs.filter(func(i): 
		var inp := i as Instruction.Register
		if not inp :
			return false
		return inp == output.instr.output)
	).is_empty()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_controller_increment_clock(clock_cycle_counter):
	semaphore = outputs.size()
