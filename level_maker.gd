extends Node
@export var first_units: Array = []

func create(pipeline: Array, size: Vector2, instructions: Array):

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

	#Execute and Writeback
	column = get_column(pipeline, size, 2)
	var curr_unit
	var prev_unit
	for unit in column:
		if unit:
			unit.previous_unit = sch_decode
			sch_decode.outputs.append(unit)
			curr_unit = unit
			break
	prev_unit = curr_unit

	var i = 3
	while (curr_unit.unit_type != Pipeline.Unit.WRITEBACK):
		column = get_column(pipeline, size, i)
		for unit in column:
			if unit:
				curr_unit = unit
				curr_unit.previous_unit = prev_unit
				prev_unit.next_unit = curr_unit
				prev_unit = curr_unit
				print("Unit type : ", curr_unit.unit_type)
				break
		i += 1
	
	##
	##Writeback
	##i -= 1
	##column = get_column(pipeline, size, i)
	##for unit in column:
	#	if unit and unit.unit_type == Pipeline.Unit.WRITEBACK:
	#		curr_unit = unit
	#		curr_unit.previous_unit = prev_unit
	#		prev_unit.next_unit = curr_unit
	#		prev_unit = curr_unit
	#		break

	#Commiter
	prev_unit.next_unit = Commiter.new()
	curr_unit = prev_unit.next_unit
	curr_unit.inputs = [prev_unit]
	add_child(curr_unit)

	# Instantiate the controller
	var controller = Controller.new()
	add_child(controller)
	controller.instructions = instructions
	controller.instruction_count = instructions.size()
	controller.first_units = first_units
	controller.last_unit = curr_unit

	controller.set_timer()
	print("Controller is in scene tree : ", controller.is_inside_tree())

	controller.run()

func find_neighbours(i: int, j: int):
	pass
	
func get_column(pipeline: Array, size: Vector2, i: int) -> Array:
	var res = []
	for idx in range(i * size.y, (i + 1) * size.y):
		res.append(pipeline[idx])
	return res
