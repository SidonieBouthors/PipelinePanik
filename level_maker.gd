extends Node
@export var first_units: Array = []
@export var last_units: Array = []

func create(pipeline: Array, size: Vector2, instructions: Array, rob_size: int = 10):

	#Fetch
	var column = get_column(pipeline, size, 0)
	var sch_fetch = Scheduler.new()
	add_child(sch_fetch)
	for unit in column:
		if unit and unit.unit_type == Pipeline.Unit.FETCH:
			first_units.append(unit)
			unit.next_unit = sch_fetch
			unit.previous_unit = null
			sch_fetch.inputs.append(unit)

	#Decode
	column = get_column(pipeline, size, 1)
	var sch_decode = Scheduler.new()
	add_child(sch_decode)
	for decode in column:
		if decode and decode.unit_type == Pipeline.Unit.DECODE:
			decode.next_unit = sch_decode
			decode.previous_unit = sch_fetch
			sch_decode.inputs.append(decode)
			sch_fetch.outputs.append(decode)
	sch_fetch.update_semaphore()

	# ROB
	var rob = ROB.new(rob_size)
	add_child(rob)

	#Execute and Writeback
	column = get_column(pipeline, size, 2)
	var curr_unit
	var prev_unit
	var line = 0
	for unit in column:
		if unit:
			unit.previous_unit = sch_decode
			sch_decode.outputs.append(unit)
			curr_unit = unit

			var next_units = get_line(pipeline, size, line, 3)
			var next_unit_feur
			for next_unit in next_units:
				next_unit_feur = next_unit
				if next_unit:
					if next_unit.unit_type != Pipeline.Unit.WRITEBACK:
						next_unit.previous_unit = curr_unit
						curr_unit.next_unit = next_unit
						curr_unit = next_unit
					else:
						curr_unit.next_unit = rob
						rob.inputs.append(curr_unit)

						# next_unit is a writeback
						rob.outputs.append(next_unit)
						next_unit.previous_unit = rob
						last_units.append(next_unit)
			
			if not next_unit_feur:
				curr_unit.next_unit = rob
				rob.inputs.append(curr_unit)

		line += 1

	sch_decode.update_semaphore()
	rob.update_semaphore()
	
	#Commiter
	var commiter = Commiter.new()
	add_child(curr_unit)
	commiter.inputs = last_units

	for last_unit in last_units:
		last_unit.next_unit = commiter

	# Instantiate the controller
	var controller = Controller.new()
	add_child(controller)
	controller.instructions = instructions
	controller.instruction_count = instructions.size()
	controller.first_units = first_units
	controller.last_unit = commiter
	controller.map = pipeline

	controller.set_timer()
	print("Controller is in scene tree : ", controller.is_inside_tree())

	controller.run()

func get_column(pipeline: Array, size: Vector2, i: int) -> Array:
	var res = []
	for idx in range(i * size.y, (i + 1) * size.y):
		res.append(pipeline[idx])
	return res

func get_line(pipeline: Array, size: Vector2, j: int, from: int = 0) -> Array:
	var res = []
	for idx in range(from, size.x):
		res.append(pipeline[idx * size.y + j])
	return res
