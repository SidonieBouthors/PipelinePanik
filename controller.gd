extends Node
class_name Controller

@onready var timer: Timer = get_node("Timer")

var clock_cycle_counter := 0
var instructions : Array
var first_units : Array
var last_unit: Unit

signal increment_clock(clock_cycle_counter)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(timer)
	start_clock()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	_print_state()
	
	clock_cycle_counter += 1

	for unit in first_units :
		if not unit.is_stalled :
			unit.instr = instructions.pop_at(0)
	
	increment_clock.emit(clock_cycle_counter)
	
	if last_unit:
		last_unit.run()

func run():
	start_clock()

func start_clock():
	timer.start()
	pass

func pause_clock():
	timer.stop()
	pass
	
func reset_counter():
	clock_cycle_counter = 0
	pause_clock()

func _print_state():
	print("Clock cycle: ", clock_cycle_counter)

	if not first_units.is_empty():
		var unit = first_units[0]
		while unit:
			print("Unit Type:", unit.unit_type)
			print("   Instruction Type:", unit.instr.type)
			print("   Program Counter:", unit.instr.pc)
			print("   Is Stalled:", unit.is_stalled)
			print("")
			unit = unit.next_unit

		print("")
