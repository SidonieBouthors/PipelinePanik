extends Node
class_name Scheduler

var inputs: Array
var outputs: Array
var semaphore : int

# Available inputs = inputs - NOPs
var available_inputs = []

# Available outputs = outputs - stalled outputs
var available_outputs = []

func scheduler():
	update_available()

	var inputs_to_skip = {}
	var outputs_to_skip = {}

	for input in available_inputs:
		if input not in inputs_to_skip:
			for output in available_outputs:
				if output not in outputs_to_skip:
					if is_type_compat(input, output) and is_independent(input, output):
						schedule(input, output)
						inputs_to_skip[input] = true
						outputs_to_skip[output] = true
				
# Schedule the current instruction of `old` to `new`
func schedule(old: Unit, new: Unit):
	if old.instr and old.instr.type != Instruction.Type.NOP:
		new.instr = old.instr
		old.instr = null

func update_available():
	available_inputs = inputs.filter(func(unit: Unit): 
		return unit.instr.type != Instruction.Type.NOP
	)

	available_outputs = outputs.filter(func(unit: Unit): 
		return unit.stalled == false
	)
	
func update_stall():
	pass

func is_type_compat(unit1 : Unit, unit2: Unit):
	return unit1.instr.type == unit2.instr.type
	
func is_independent(input: Unit, output: Unit):
	return input.instr.inputs.filter(func(i): 
		var inp := i as Instruction.Register

		# if input is not a register (e.g. immediate), it is always independent
		if not inp :
			return false
		
		return inp == output.instr.output
	).is_empty()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_controller_increment_clock(clock_cycle_counter):
	semaphore = outputs.size()

# Can be called multiple times per clock cycle (if multiple outputs)
func run():
	semaphore -= 1

	# If all outputs are done, run the scheduler
	if semaphore == 0:
		scheduler()

		for unit in inputs:
			unit.run()
