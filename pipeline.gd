extends Node2D
class_name Pipeline

const unit = preload("res://unit.tscn")
const dropZone = preload("res://dropzone.tscn")
const levelMaker = preload("res://level_maker.tscn")

const unitImages = [
	preload("res://assets/fetch-box.png"),
	preload("res://assets/decode-box.png"),
	preload("res://assets/execute-box.png"),
	preload("res://assets/memory-box.png"),
	preload("res://assets/writeback-box.png"),
	]

enum Unit {
	FETCH,
	DECODE,
	ALU,
	MEMORY,
	WRITEBACK,
	SCHEDULER,
	NONE
}

@export var pipeline_state := []

var instructions = []

@export var drop_zones := []

# The grid's size in columns and rows.
@export var size := Vector2(5, 3)
# The size of a cell in pixels.
@export var cell_size := Vector2(64, 64)

var _half_cell_size = cell_size / 2

var level

var first_start = true

# Called when the node enters the scene tree for the first time.
func _ready():
	level = levelMaker.instantiate()
	add_child(level)
	
	set_position(Vector2(128, 0))
	for i in (size.x * size.y):
		pipeline_state.append(null)
		drop_zones.append(null)
		
	for i in size.x:
		for j in size.y:
			var drop = dropZone.instantiate()
			drop.position = calculate_map_position(Vector2(i, j))
			get_node(".").add_child(drop)
			drop_zones[i * size.y + j] = drop
			
	fill_instructions()
			

# Returns the position of a cell's center in pixels.
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size
	
# Returns the coordinates of the cell on the grid given a position on the map.
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()
	
# Returns true if the cell_coordinates are within the grid.
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < size.y
	
# Makes the grid_position fit within the grid's bounds.
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out
	
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)

func calc_pipeline():
	for i in size.x:
		for j in size.y:
			pipeline_state[i * size.y + j] = drop_zones[i * size.y + j].occupant
	
func add_unit(type):
	var sprite = unit.instantiate()
	sprite.unit_type = type
	sprite.set_sprite(unitImages[type])
	sprite.position = get_local_mouse_position()
	get_node(".").add_child(sprite)
	sprite._on_mouse_entered()


func _on_f_button_down():
	add_unit(Unit.FETCH)

func _on_d_button_down():
	add_unit(Unit.DECODE)

func _on_e_button_down():
	add_unit(Unit.ALU)

func _on_m_button_down():
	add_unit(Unit.MEMORY)

func _on_w_button_down():
	add_unit(Unit.WRITEBACK)

func _on_play_button_pressed():
	if first_start:
		calc_pipeline()
		print(pipeline_state)
		level.create(pipeline_state, size, instructions)
		first_start = false
	else:
		var controller

		for child in level.get_children():
			if child as Controller:
				controller = child

		controller.toggle_clock()

func _on_restart_button_pressed():
	# Level Maker children:
	# 
	"""
	Level Maker children:
		- Controller
		- ROB
		- Commiter
		- Schedulers (always 2)
	"""
	level.get_children().map(func (child): child.clear())

	"""
	Pipeline children:
		- All units
	"""
	pipeline_state.map(func (u): if u: u.clear())

	instructions.map(func (i): if i as Instruction: i.queue_free())

	fill_instructions()
	level.reset(instructions)

func fill_instructions():
	# Clear the instructions
	instructions = []

	# First instruction: ADD r0, r1, r2
	var instruction = Instruction.new(0, Instruction.Type.ALU, [Instruction.Register.r1, Instruction.Register.r2], Instruction.Register.r0)
	add_child(instruction)
	instructions.append(instruction)

	# Second instruction: ADD r1, r1, r2
	instruction = Instruction.new(1, Instruction.Type.ALU, [Instruction.Register.r1, Instruction.Register.r2], Instruction.Register.r1)
	add_child(instruction)
	instructions.append(instruction)

	# Third instruction: ADD r2, r1, r2
	instruction = Instruction.new(2, Instruction.Type.ALU, [Instruction.Register.r1, Instruction.Register.r2], Instruction.Register.r2)
	add_child(instruction)
	instructions.append(instruction)


	# Fourth instruction: LW r3, 0(r0)
	instruction = Instruction.new(3, Instruction.Type.MEM, [0, Instruction.Register.r0], Instruction.Register.r3)
	add_child(instruction)
	instructions.append(instruction)
	
	$"../../UILayer/CodeContainer/InstructionsPanel".repopulate(instructions)
