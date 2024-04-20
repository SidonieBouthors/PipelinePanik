extends Node
class_name Unit

var unit_type: Pipeline.Unit
var instr : Instruction
var is_stalled : bool = false

# Either a unit or a scheduler
var previous_unit 
var next_unit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_controller_increment_clock(clock_cycle_counter):
	print(clock_cycle_counter)
	
func update_instruction(instruction):
	instr = instruction
	
# Run the unit every clock cycle. 
# Note that the simulation starts at the end of the pipeline and 
# then backtracks to the beginning.
func run():
	if previous_unit:
		var prev := previous_unit as Scheduler

		if prev:
			# if previous is a scheduler
			pass
		else:
			# if previous is a unit
			if is_stalled:
				previous_unit.is_stalled = true
			else:
				instr = previous_unit.instr
				previous_unit.instr = null
		previous_unit.run()

func find_types() -> Array:
	return []
