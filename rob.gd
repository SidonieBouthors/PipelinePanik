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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func commit():
	pass

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

# Can be called multiple times per clock cycle (if multiple outputs)
func run():
	semaphore -= 1

	if semaphore == 0:
		var available_units = get_ready_units(inputs)

		for unit in available_units:
			if unit.instr.pc < pc + size:
				stack.append(unit.instr)

				unit.is_stalled = false
				unit.instr = null

				pc += 1
			else:
				unit.is_stalled = true
		
		for unit in outputs:
			if stack.size() > 0:
				unit.instr = stack.pop_front()
			else:
				unit.instr = null
		
		for unit in inputs:
			unit.run()

		update_semaphore()
