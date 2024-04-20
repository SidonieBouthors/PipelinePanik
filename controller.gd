extends Node
class_name Controller

@export var timer_wait_time = 1.0
var timer: Timer

var clock_cycle_counter = 0
var instructions : Array
var first_units : Array
var last_units : Array

var scheduler_list : Array = []

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

func searchAllSchedulers(unit, accumulator):
	if not unit:
		return

	if unit is Scheduler:
		if unit not in accumulator:
			accumulator.append(unit)
			for output in unit.outputs:
				searchAllSchedulers(output, accumulator)
	else:
		searchAllSchedulers(unit.next_unit, accumulator)

func _on_timer_timeout():
	if clock_cycle_counter == 0:
		for unit in first_units:
			searchAllSchedulers(unit, scheduler_list)

	for sch in scheduler_list:
		sch.update_semaphore()
	
	clock_cycle_counter += 1

	for unit in first_units :
		if not unit.is_stalled :
			unit.instr = instructions.pop_at(0)
	
	for unit in last_units :
		unit.run()
	
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
	timer.wait_time = timer_wait_time
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _print_state():
	print("Clock cycle: ", clock_cycle_counter)

	if not first_units.is_empty():
		var unit = first_units[0]
		while unit:
			if unit is Scheduler:
				print("   Scheduler")
				unit = unit.outputs[0]
			else:
				print("   Unit Type: ", Pipeline.Unit.keys()[unit.unit_type])
				print("   Instruction: ", Instruction.Type.keys()[unit.instr.type] if unit.instr else "None")
				print("   Program Counter: ", unit.instr.pc if unit.instr else "None")
				print("   Is Stalled: ", unit.is_stalled)
				unit = unit.next_unit
			print("")

		print("")
