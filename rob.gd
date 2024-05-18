extends Node
class_name ROB

@export var inputs: Array = []
@export var outputs: Array = []

# Stack is the list of instructions that are waiting to be written back
@export var stack: Array = []
@export var size: int = 0

# Current PC counter (to commit in order)
@export var pc: int = 0

@export var semaphore: int = 0

func _init(s: int):
	size = s

func update_semaphore():
	semaphore = outputs.size()

# Assuming both units have a valid instruction
func sort_pc_ascending(unit1: Unit, unit2: Unit) -> bool:
	if unit1.instr.pc < unit2.instr.pc:
		return true
	else:
		return false

func get_ready_units(units: Array) -> Array:
	var res = []
	for unit in units:
		if unit.instr:
			res.append(unit)
	
	res.sort_custom(sort_pc_ascending)
	return res

func sort_pc_instr(instr1: Instruction, instr2: Instruction) -> bool:
	if instr1.pc < instr2.pc:
		return true
	else:
		return false

# Can be called multiple times per clock cycle (if multiple outputs)
func run():
	semaphore -= 1

	if semaphore == 0:
		var available_units = get_ready_units(inputs)

		# First fill the stack with instructions that are ready to be written back
		for unit in available_units:
			if not unit.instr:
				continue
			
			if unit.instr.pc < pc + size:
				stack.append(unit.instr)

				unit.is_stalled = false
				unit.instr = null
			else:
				unit.is_stalled = true

		# Then assign instructions in order to the writebacks
		for unit in outputs:
			if stack.size() > 0:
				stack.sort_custom(sort_pc_instr)
				if stack[0].pc == pc:
					unit.instr = stack.pop_front()
					pc += 1
			else:
				unit.instr = null

		
		
		for unit in inputs:
			unit.run()

		update_semaphore()

func clear():
	stack.clear()
	pc = 0
	update_semaphore()
