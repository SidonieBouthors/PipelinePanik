extends Node2D

enum Units {
	FETCH,
	DECODE,
	EXECUTE,
	MEMORY,
	WRITEBACK
}

# The grid's size in rows and columns.
@export var size := Vector2(5, 3)
# The size of a cell in pixels.
@export var cell_size := Vector2(64, 64)

var _half_cell_size = cell_size / 2

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_f_box_pressed():
	pass # Replace with function body.


func _on_f_pressed():
	pass # Replace with function body.
