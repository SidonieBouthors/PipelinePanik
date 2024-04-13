extends Node
class_name Controller
var clock_cycle_counter := 0
var instructions : Array
var first_units : Array
signal increment_clock(clock_cycle_counter)


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_counter()
	start_clock()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	clock_cycle_counter += 1
	for unit in first_units :
		if not unit.is_stalled :
			unit.update_instruction(instructions.pop_at(0))
	increment_clock.emit(clock_cycle_counter)
	
func start_clock():
	$Timer.start()
	
func reset_counter():
	clock_cycle_counter = 0
	$Timer.stop()

	
