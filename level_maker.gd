extends Node
@export var first_units: Array = []

func create(pipeline: Array, size: Vector2, instructions: Array):

	#Fetch
	var column = get_column(pipeline, size, 0)
	var sch_fetch = Scheduler.new()
	add_child(sch_fetch)
	for unit in column:
		if unit and unit.unit_type == Pipeline.Unit.FETCH:
			var fetch = Unit.new()
			fetch.unit_type = Pipeline.Unit.FETCH
			fetch.next_unit = sch_fetch
			fetch.previous_unit = null
			sch_fetch.inputs.append(fetch)
			add_child(fetch)

	#Decode
	column = get_column(pipeline, size, 1)
	var sch_decode = Scheduler.new()
	add_child(sch_decode)
	for unit in column:
		if unit and unit.unit_type == Pipeline.Unit.DECODE:
			var decode = Unit.new()
			decode.unit_type = Pipeline.Unit.DECODE
			decode.next_unit = sch_decode
			decode.previous_unit = sch_fetch
			sch_decode.inputs.append(decode)
			sch_fetch.outputs.append(decode)
			add_child(decode)

	#Execute


func find_neighbours(i: int, j: int):
	pass
	
	
func get_column(pipeline: Array, size: Vector2, i: int) -> Array:
	var res = []
	for idx in range(i * size.x, (i+1)*size.x):
		res.append(pipeline[idx])
	return res
	
