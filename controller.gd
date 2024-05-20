extends Node
class_name Controller

@export var timer_wait_time = 3.0
var timer: Timer
var score = 0.0

var clock_cycle_counter = 0
var instructions: Array
var instruction_count: int
var first_units: Array
var last_unit: Commiter

var components: Array = []

func _init(_instructions : Array, _first_units : Array, _last_unit : Commiter, _components: Array):
	instructions = _instructions
	instruction_count = _instructions.size()
	first_units = _first_units
	last_unit = _last_unit
	components = _components


# Main function, called every clock cycle. It handles the simulation of the pipeline
func _on_timer_timeout():
	pop_instructions(first_units, instructions)
	_print_state()
	_draw_state()
	
	clock_cycle_counter += 1

	score = float(last_unit.number_of_commits) / clock_cycle_counter
	var parent = self.get_parent()
	while parent.name != "Node2D":
		parent = parent.get_parent()
	var scorePanel = parent.find_child("ScorePanel")
	scorePanel.set_label(score)

	#if last unit contains the last instruction, then we are done
	var pc = last_unit.instructions.map(func(instr):
		if instr == null:
			return null
		else: return instr.pc)
	if (instruction_count - 1) in pc:
		end_game()
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
	timer.start()

func toggle_clock():
	if (timer.is_stopped()):
		timer.start()
	else:
		timer.stop()
	
func reset_counter():
	clock_cycle_counter = 0
	timer.stop()

func set_timer():
	timer = Timer.new()
	timer.wait_time = timer_wait_time
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false
	add_child(timer)

func change_speed(faster : bool):
	if faster:
		if timer_wait_time >= 2:
			timer_wait_time-=1
	else:
		if timer_wait_time <=4:
			timer_wait_time+=1
	timer.wait_time = timer_wait_time

func _print_state():
	print()
	print("Clock cycle: ", clock_cycle_counter)

	for unit in components:
		if unit is Unit:
			if unit.is_stalled:
					SoundManager.play("main", "alert")
			if unit.unit_type == Pipeline.Unit.WRITEBACK:

				if unit.instr:
					print("Writeback : ", unit.instr.pc)
			
		elif unit is Commiter:
			print("Committer: ", unit.instructions.map(func(i): 
				if i:
					return i.pc))
		
	print()

func _draw_state() :
	if not first_units.is_empty():
		for u in components:
			if u is Unit:
				if u.instr:
					u.draw_instruction(u.instr)
				else:
					u.hide_instruction()
			elif u is ROB:
				#Recursively traverse the tree to find the ROB UI
					var parent = u.get_parent()
					while parent.name != "Node2D":
						parent = parent.get_parent()
					var rob = parent.find_child("ROB")
					rob.repopulate(u.stack)

func end_game():
	MusicManager.disable_stem("simulation")
	toggle_clock()
	print("Simulation done")
	print("Score : ", score, " IPC")
	var parent = self.get_parent()
	while parent.name != "Node2D":
		parent = parent.get_parent()
	var endLevel = parent.find_child("EndLevel")
	endLevel.find_child("Score").text = "Score: " + str(snapped(score, 0.01)) + " IPC"
	endLevel.visible = true
	endLevel.find_child("NextLevel").grab_focus()


func clear():
	instructions = []
	instruction_count = 0
	reset_counter()
