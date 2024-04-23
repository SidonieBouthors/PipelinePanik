extends Node

var first_unit: Unit = Unit.new()

var instructions: Array = []
var first_units: Array = []
var last_unit: Commiter

# Called when the node enters the scene tree for the first time.
func _ready():
	var curr_unit
	var prev_unit = null
	
	# Fetch
	curr_unit = first_unit
	curr_unit.previous_unit = prev_unit
	curr_unit.next_unit = Decoder.new()
	curr_unit.unit_type = Pipeline.Unit.FETCH
	add_child(curr_unit)
	
	# Decode
	prev_unit = curr_unit
	curr_unit = curr_unit.next_unit
	curr_unit.previous_unit = prev_unit
	curr_unit.next_unit = Scheduler.new()
	curr_unit.unit_type = Pipeline.Unit.DECODE
	add_child(curr_unit)
	
	# Scheduler
	prev_unit = curr_unit
	curr_unit = curr_unit.next_unit
	curr_unit.inputs = [prev_unit]
	curr_unit.outputs = [Unit.new()]
	add_child(curr_unit)

	# ALU
	prev_unit = curr_unit
	curr_unit = curr_unit.outputs[0]
	curr_unit.previous_unit = prev_unit
	curr_unit.next_unit = Unit.new()
	curr_unit.unit_type = Pipeline.Unit.ALU
	add_child(curr_unit)

	# Writeback
	prev_unit = curr_unit
	curr_unit = curr_unit.next_unit
	curr_unit.previous_unit = prev_unit
	curr_unit.next_unit = Commiter.new()
	curr_unit.unit_type = Pipeline.Unit.WRITEBACK
	add_child(curr_unit)
	
	
	#Commiter
	prev_unit = curr_unit
	curr_unit = curr_unit.next_unit
	curr_unit.inputs = [prev_unit]
	add_child(curr_unit)

	
	first_units.append(first_unit)
	last_unit = curr_unit

	# First instruction: ADD r0, r1, r2
	var instruction = Instruction.new()
	add_child(instruction)
	instruction.pc = 0
	instruction.type = Instruction.Type.ALU
	instruction.output = Instruction.Register.r0
	instruction.inputs = [Instruction.Register.r1, Instruction.Register.r2]
	instructions.append(instruction)

	# Second instruction: ADD r1, r1, r2
	instruction = Instruction.new()
	add_child(instruction)
	instruction.pc = 1
	instruction.type = Instruction.Type.ALU
	instruction.output = Instruction.Register.r1
	instruction.inputs = [Instruction.Register.r1, Instruction.Register.r2]
	instructions.append(instruction)

	# Third instruction: ADD r2, r1, r2
	instruction = Instruction.new()
	add_child(instruction)
	instruction.pc = 2
	instruction.type = Instruction.Type.ALU
	instruction.output = Instruction.Register.r2
	instruction.inputs = [Instruction.Register.r1, Instruction.Register.r2]
	instructions.append(instruction)

	# Instantiate the controller
	var controller = Controller.new()
	add_child(controller)
	controller.instructions = instructions
	controller.first_units = first_units
	controller.last_unit = last_unit
	
	controller.set_timer()

	controller.run()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
