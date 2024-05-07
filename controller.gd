extends Node
class_name Controller

@export var timer_wait_time = 3.0
var timer: Timer

var clock_cycle_counter = 0
var instructions: Array
var instruction_count: int
var first_units: Array
var last_unit: Commiter

var scheduler_list: Array = []
var components: Array = []

signal increment_clock(clock_cycle_counter)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#set_timer()
	#start_clock()

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _init(_instructions : Array, _instruction_count : int, _first_units : Array, _last_unit : Commiter, _components: Array):
	instructions = _instructions
	instruction_count = _instruction_count
	first_units = _first_units
	last_unit = _last_unit
	components = _components

func searchAllSchedulers(unit, accumulator):
	if not unit:
		return

	if unit is Scheduler:
		if unit not in accumulator:
			accumulator.append(unit)
			for output in unit.outputs:
				searchAllSchedulers(output, accumulator)
	elif unit is Commiter:
		return
	else:
		searchAllSchedulers(unit.next_unit, accumulator)

func _on_timer_timeout():
	pop_instructions(first_units, instructions)
	_print_state()
	_draw_state()
	
	clock_cycle_counter += 1
	#if last unit contains the last instruction, then we are done
	var pc = last_unit.instructions.map(func(instr):
		if instr == null:
			return null
		else: return instr.pc)
	if (instruction_count - 1) in pc:
		pause_clock()
		print("Simulation done")
		print("Score : ", str(float(instruction_count)/clock_cycle_counter), " IPC")
		return
	else:
		last_unit.run()

func pop_instructions(units: Array, instr: Array):
	for unit in units:
		if not unit.is_stalled:
			unit.instr = instr.pop_front()

func run():
	start_clock()

#E 0:00:46:0634   controller.gd:66 @ start_clock(): Timer was not added to the SceneTree. Either add it or set autostart to true.
func start_clock():
	if timer.is_inside_tree():
		timer.start()
	else:
		print("Timer not in scene tree")

func pause_clock():
	timer.stop()
	
func reset_counter():
	clock_cycle_counter = 0
	pause_clock()

func set_timer():
	timer = Timer.new()
	timer.wait_time = timer_wait_time
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false
	add_child(timer)

func _print_state():
	print("Clock cycle: ", clock_cycle_counter)

	if not first_units.is_empty():
		var unit = first_units[0]
		while unit:
			if unit is Scheduler:
				print("   Scheduler")
				unit = unit.outputs[0]
			elif unit is Commiter:
				print("   Commiter")
				for instr in unit.instructions:
					if instr:
						print("   PC : ", instr.pc)
				unit = null
			elif unit is ROB:
				print("   Reorder Buffer")
				for instr in unit.stack:
					if instr:
						print("   PC : ", instr.pc)
				unit = null
			else:
				# if unit.instr:
				# 	unit.draw_instruction(unit.instr)
				# else:
				# 	unit.hide_instruction()
				print("   Unit Type: ", Pipeline.Unit.keys()[unit.unit_type])
				print("   Instruction: ", Instruction.Type.keys()[unit.instr.type] if unit.instr else "None")
				print("   Program Counter: ", unit.instr.pc if unit.instr else "None")
				print("   Is Stalled: ", unit.is_stalled)
				unit = unit.next_unit
			print("")

		print("")

func _draw_state() :
	if not first_units.is_empty():
		for u in components:
			if u is Unit:
				if u.instr:
					u.draw_instruction(u.instr)
				else:
					u.hide_instruction()

