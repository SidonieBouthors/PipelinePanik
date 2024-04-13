extends Node
class_name Unit
var instr : Instruction 
var is_stalled : bool = false

#Either a unit or a scheduler
var previous_unit 
var next_unit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_instr() :
	pass


func _on_controller_increment_clock(clock_cycle_counter):
	print(clock_cycle_counter)
	
func update_instruction(instruction):
	instr = instruction
	
func update_stall():
	if previous_unit != null:
		if is_stalled:
			previous_unit.is_stalled = true
		previous_unit.update_stall()
