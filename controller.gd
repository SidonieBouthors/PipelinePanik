extends Node
class_name Controller

@export var timer_wait_time = 1.0
var timer: Timer

var clock_cycle_counter = 0
var instructions : Array
var first_units : Array
var last_unit: Unit

signal increment_clock(clock_cycle_counter)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("ready called")
	#set_timer()
	#start_clock()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	clock_cycle_counter += 1

	for unit in first_units :
		if not unit.is_stalled :
			unit.instr = instructions.pop_at(0)
	
	increment_clock.emit(clock_cycle_counter)
	
	if last_unit:
		last_unit.run()
	
	_print_state()

func run():
	start_clock()

func start_clock():
	timer.start()

func pause_clock():
	timer.stop()
	
func reset_counter():
	clock_cycle_counter = 0
	pause_clock()

func set_timer():
	timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = timer_wait_time
	timer.timeout.connect(_on_timer_timeout)

func _print_state():
	print("Clock cycle: ", clock_cycle_counter)

	if not first_units.is_empty():
		var unit = first_units[0]
		while unit:
			if unit is Scheduler:
				print("   Scheduler")
				unit = unit.outputs[0]
			else:
				print("   Unit Type: ", unit.unit_type if unit.unit_type else "null")
				print("   Type from Enum: ", Pipeline.Unit.keys()[unit.unit_type] if unit.unit_type else "null")
				print("   Instruction Type: ", unit.instr.type if unit.instr else "null")
				print("   Program Counter: ", unit.instr.pc if unit.instr else "null")
				print("   Is Stalled: ", unit.is_stalled if unit.is_stalled else "null")
				unit = unit.next_unit
			print("")

		print("")
