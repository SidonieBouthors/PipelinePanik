extends Node
class_name Scheduler

@export var inputs: Array = []
@export var outputs: Array = []
@export var semaphore: int
@export var components: Array = []

# Available inputs = inputs - NOPs
var available_inputs = []

# Available outputs = outputs - stalled outputs
var available_outputs = []

func scheduler():
	update_available()

	var inputs_to_skip = {}

	for input in available_inputs:
		if input not in inputs_to_skip:
			var unit
			if input.unit_type == Pipeline.Unit.FETCH:
				# if input is a fetch unit, schedule it to the first available output (decode)
				if not available_outputs.is_empty():
					unit = available_outputs[0]
			else:
				# if input is not a fetch unit, find a compatible unit
				unit = get_compatible_unit(input.instr, available_outputs)

			if unit:
				schedule(input, unit)
				inputs_to_skip[input] = true
				available_outputs = available_outputs.filter(
					func(i: Unit):
						return i != unit
			)
			else:
				# if no compatible unit found (e.g. all units are busy/dependant), 
				# stall the input
				input.is_stalled = true
				
# Schedule the current instruction of `old` to `new`
func schedule(old: Unit, new: Unit):
	if old.instr:
		new.instr = old.instr
		old.instr = null
		old.is_stalled = false

func update_available():
	available_inputs = inputs.filter(func(unit: Unit):
		return unit.instr != null
	)
	
	available_inputs.sort_custom(func(a: Unit, b: Unit):
		return a.instr.pc < b.instr.pc
	)

	available_outputs = outputs.filter(func(unit: Unit):
		return unit.is_stalled == false
	)
	
func update_stall():
	pass

func is_type_compat(instruction: Instruction, unit: Unit) -> bool:
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
	if is_dependent(instruction):
		return null

	var pool: Dictionary = {}
	var i = 0

	for unit in units:
		pool[unit] = i

	while not pool.is_empty():
		for unit in pool.keys():
			if is_type_compat(instruction, unit):
					var u = unit
					while not (u.previous_unit is Scheduler):
						u = u.previous_unit
					return u

		i += 1

		for unit in pool.keys():
			if unit is Scheduler:
				for child in unit.inputs:
					pool[child] = i
			else:
				if unit.next_unit and not (unit.next_unit as ROB):
					pool[unit.next_unit] = i
			
			pool.erase(unit)

	return null
	
func is_instr_independent(input: Instruction, output: Instruction) -> bool:
	return input.inputs.filter(func(i):
		var inp:=i as Instruction.Register

		# if input is not a register (e.g. immediate), it is always independent
		if not inp:
			return false
		
		return inp == output.output
	).is_empty()

func is_dependent(instruction: Instruction) -> bool:
	for comp in components:
		if comp is Unit:
			if comp.instr and comp.instr.pc < instruction.pc:
				if not is_instr_independent(instruction, comp.instr):
					return true
		elif comp is Commiter:
			for instr in comp.instructions:
				if instr and instr.pc < instruction.pc:
					if not is_instr_independent(instruction, instr):
						return true
		elif comp is ROB:
			for instr in comp.stack:
				if instr and instr.pc < instruction.pc:
					if not is_instr_independent(instruction, instr):
						return true
	return false

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
		
		update_semaphore()

func clear():
	update_semaphore()
