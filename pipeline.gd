extends Node2D
class_name Pipeline

const unitVisual = preload("res://unit.tscn")
const dropZone = preload("res://dropzone.tscn")

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

@export var drop_zones := []

# The grid's size in columns and rows.
@export var size := Vector2(5, 3)
# The size of a cell in pixels.
@export var cell_size := Vector2(64, 64)

var _half_cell_size = cell_size / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	set_position(Vector2(128, 0))
	for i in (size.x * size.y):
		pipeline_state.append(Unit.NONE)
		drop_zones.append(null)
	for i in size.x:
		for j in size.y:
			var drop = dropZone.instantiate()
			drop.position = calculate_map_position(Vector2(i, j))
			get_node(".").add_child(drop)
			drop_zones[i * size.y + j] = drop
			

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
	
func add_unit(unit):
	var empty
	var sprite = unitVisual.instantiate()
	sprite.set_sprite(unitImages[unit])
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
