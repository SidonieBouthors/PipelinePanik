extends Node
class_name Scheduler

@export var inputs: Array
@export var outputs: Array
@export var semaphore : int

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
			var unit = get_compatible_unit(input.instr, available_outputs.filter(
				func(i: Unit): 
					return i not in outputs_to_skip
			))

			if unit:
				schedule(input, unit)
				inputs_to_skip[input] = true
				outputs_to_skip[unit] = true
			else:
				# if no compatible unit found (e.g. all units are busy/dependant), 
				# stall the input
				input.is_stalled = true
				
# Schedule the current instruction of `old` to `new`
func schedule(old: Unit, new: Unit):
	if old.instr:
		new.instr = old.instr
		old.instr = null

func update_available():
	available_inputs = inputs.filter(func(unit: Unit): 
		return unit.instr != null
	)

	available_outputs = outputs.filter(func(unit: Unit): 
		return unit.is_stalled == false
	)
	
func update_stall():
	pass

func is_type_compat(instruction : Instruction, unit: Unit) -> bool:
	var type = false

	match instruction.type:
		Instruction.Type.ALU:
			type = unit.unit_type == Pipeline.Unit.ALU
		Instruction.Type.MEM:
			type = unit.unit_type == Pipeline.Unit.MEMORY
		Instruction.Type.BRANCH:
			type = true

	return type

func get_compatible_unit(instruction: Instruction, units: Array) -> Unit:
	if is_dependent(instruction, outputs):
		return null

	var pool: Dictionary = {}
	var i = 0

	for unit in units:
		pool[unit] = i

	while not pool.is_empty():
		for unit in pool.keys():
			if is_type_compat(instruction, unit):
					return unit

		i += 1

		for unit in pool.keys():
			if unit is Scheduler:
				for child in unit.inputs:
					pool[child] = i
			else:
				if unit.next_unit and unit.next_unit.unit_type != Pipeline.Unit.WRITEBACK:
					pool[unit.next_unit] = i
			
			pool.erase(unit)

	return null
	
func is_instr_independent(input: Instruction, output: Instruction) -> bool:
	return input.inputs.filter(func(i): 
		var inp := i as Instruction.Register

		# if input is not a register (e.g. immediate), it is always independent
		if not inp :
			return false
		
		return inp == output.output
	).is_empty()

func is_dependent(instruction: Instruction, out: Array) -> bool:
	if out.filter(func(unit: Unit): 
		return unit != null
	).is_empty():
		return false

	var dependent = false

	for output in out:
		if output is Scheduler:
			dependent = is_dependent(instruction, output.outputs)

			if dependent:
				return true
		elif output is Commiter:
				for instr in output.instructions:
					if instr:
						dependent = not is_instr_independent(instruction, instr)
						if dependent:
							return true
		else:
			if output.instr:
				dependent = not is_instr_independent(instruction, output.instr)
				
				if dependent:
					return true

			dependent = is_dependent(instruction, [output.next_unit])

			if dependent:
				return true
						

	return false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_semaphore():
	semaphore = outputs.size()

# Can be called multiple times per clock cycle (if multiple outputs)
func run():
	semaphore -= 1

	# If all outputs are done, run the scheduler
	if semaphore == 0:
		scheduler()

		for unit in inputs:
			unit.run()
