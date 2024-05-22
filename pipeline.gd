/*
    Pipeline Panik, processor pipelining game
    Copyright (C) 2024  Clément Josso, Patrick Pataky, Massimo Berardi, Sidonie Bouthors

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

extends Node2D
class_name Pipeline

const unit = preload ("res://unit.tscn")
const dropZone = preload ("res://dropzone.tscn")
const levelMaker = preload ("res://level_maker.tscn")

const unitImages = [
	preload ("res://assets/fetch-box.png"),
	preload ("res://assets/decode-box.png"),
	preload ("res://assets/execute-box.png"),
	preload ("res://assets/memory-box.png"),
	preload ("res://assets/writeback-box.png"),
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
@export var cell_size := Vector2(54, 54)

var _half_cell_size = cell_size / 2

var level

var first_start = true
var is_playing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if global.level_number == 0:
		size = Vector2(5, 1)
		set_position(Vector2(105, 94))
	else:
		size = Vector2(5, 3)
		set_position(Vector2(105, 28))
		
	set_dev_score()
	
	level = levelMaker.instantiate()
	add_child(level)
	
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

	MusicManager.play("background", "main", 2.0, true)

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
	SoundManager.play("main", "coins-buy")
	
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
	
func set_dev_score():
	var devScore = get_parent().get_parent().get_node("UILayer/DevScore")
	match global.level_number:
		0:
			devScore.set_score(0.2)
		1:
			devScore.set_score(0.5)
		2:
			devScore.set_score(0.36)
		_:
			devScore.set_score(0.0)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			escape()
			
func escape():
	if is_playing:
		_on_play_button_pressed()
		var playButton = get_parent().get_parent().get_node("UILayer/PlayPanel/PlayButton")
		playButton._pressed()
	var escapeMenu = get_parent().get_parent().get_node("PopupLayer/EscapeMenu")
	escapeMenu.visible = not escapeMenu.visible
	if escapeMenu.visible:
		var resume = escapeMenu.find_child("Resume")
		resume.grab_focus()

func _on_play_button_pressed():
	is_playing = not is_playing
	if first_start:
		MusicManager.enable_stem("simulation") # Starts the simulation background sound
		calc_pipeline()
		
		#If level 0, assert the pipeline is correct
		if global.level_number == 0:
			#if it's not, reset the level and display a help box
			if not check_correct_pipeline():
				return
		level.create(pipeline_state, size, instructions)
		first_start = false
	else:
		if (is_playing):
			MusicManager.enable_stem("simulation")
		else: MusicManager.disable_stem("simulation")
		var controller = level.controller
		controller.toggle_clock()
	
# Remove all children from the scene
func _on_reset_button_pressed():
	if not first_start:
		var components = level.components
		for component in components:
			component.queue_free()
		var controller = level.controller
		controller.queue_free()
		level.first_units = []
		level.last_units = []
		level.components = []
		fill_instructions()
		first_start = true
		is_playing = false
		var playButton = get_parent().get_parent().get_node("UILayer/PlayPanel/PlayButton")
		playButton._pressed()
		
func check_correct_pipeline():
	if (pipeline_state.size() != 5 or pipeline_state[0].unit_type != Unit.FETCH or pipeline_state[1].unit_type != Unit.DECODE or (pipeline_state[2].unit_type != Unit.ALU and pipeline_state[3].unit_type != Unit.ALU) or (pipeline_state[3].unit_type != Unit.WRITEBACK and pipeline_state[4].unit_type != Unit.WRITEBACK)):
		for unit in pipeline_state:
			if unit:
				unit.queue_free()
		pipeline_state = []
		for i in (size.x * size.y):
			pipeline_state.append(null)
		first_start = true
		is_playing = false
		var playButton = get_parent().get_parent().get_node("UILayer/PlayPanel/PlayButton")
		playButton._pressed()
		get_parent().get_parent().get_node("UILayer/Level0/PanelContainer").visible = true
		return false
	return true

func fill_instructions():
	# Clear the instructions
	instructions = []
	
	if global.level_number == 0:
		# Only instructon : ADD r0, r1, r2
		var instruction = Instruction.new(0, Instruction.Type.ALU, [Instruction.Register.r1, Instruction.Register.r2], Instruction.Register.r0)
		add_child(instruction)
		instructions.append(instruction)
		
	elif global.level_number == 1:
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
	else:
		# First instruction: LW r2, 0(r0)
		var instruction = Instruction.new(0, Instruction.Type.MEM, [0, Instruction.Register.r0], Instruction.Register.r2)
		add_child(instruction)
		instructions.append(instruction)

		# Second instruction: ADD r1, r1, r3
		instruction = Instruction.new(1, Instruction.Type.ALU, [Instruction.Register.r1, Instruction.Register.r3], Instruction.Register.r1)
		add_child(instruction)
		instructions.append(instruction)

		# Third instruction: LW r3, 16(r2)
		instruction = Instruction.new(2, Instruction.Type.MEM, [16, Instruction.Register.r2], Instruction.Register.r3)
		add_child(instruction)
		instructions.append(instruction)

		# Fourth instruction: ADD r0, r1, r3
		instruction = Instruction.new(3, Instruction.Type.ALU, [Instruction.Register.r1, Instruction.Register.r3], Instruction.Register.r0)
		add_child(instruction)
		instructions.append(instruction)
	
	$"../../UILayer/CodeContainer/InstructionsPanel".repopulate(instructions)

func _on_resume_pressed():
	escape()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_next_level_pressed():
	if global.level_number < 2:
		global.level_number += 1
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		global.level_number = 0
		get_tree().change_scene_to_file("res://menu.tscn")

func _on_plus_pressed():
	var controller = level.controller
	if controller:
		controller.change_speed(true)

func _on_minus_pressed():
	var controller = level.controller
	if controller:
		controller.change_speed(false)

func _on_restart_0_pressed():
	var level0_UI = get_parent().get_parent().get_node("UILayer/Level0/PanelContainer")
	level0_UI.visible = false

func _on_help_button_pressed():
	if is_playing:
		_on_play_button_pressed()
		var playButton = get_parent().get_parent().get_node("UILayer/PlayPanel/PlayButton")
		playButton._pressed()
	var tutoPanel = get_parent().get_parent().get_node("PopupLayer/TutoPanel")
	tutoPanel.visible = not tutoPanel.visible
	if tutoPanel.visible:
		var resume = tutoPanel.find_child("ResumeTuto")
		resume.grab_focus()
