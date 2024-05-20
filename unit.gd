extends Area2D
class_name Unit

######## RUNNABLE ########

@export var unit_type: Pipeline.Unit
@export var instr : Instruction
@export var is_stalled : bool = false

# Either a unit or a scheduler
var previous_unit 
var next_unit
	
# Run the unit every clock cycle. 
# Note that the simulation starts at the end of the pipeline and 
# then backtracks to the beginning.
func run():
	if previous_unit:
		# TODO: check this causes a crash
		var prev := (previous_unit as Scheduler) or (previous_unit as ROB)

		if prev:
			# if previous is a scheduler or a ROB
			pass
		else:
			# if previous is a unit
			previous_unit.is_stalled = is_stalled
			if not is_stalled:
				instr = previous_unit.instr
				previous_unit.instr = null
		previous_unit.run()

func clear():
	instr = null
	is_stalled = false
	
	
######## VISUAL ########

const instruction_panel = preload("res://instruction_panel.tscn")

var draggable = false
var is_inside_dropzone = false
var zone_ref: DropZone
var offset: Vector2
var initialPos: Vector2
var noPos: bool

func set_sprite(image):
	get_child(0).texture = image

func _ready():
	noPos = true
	$InstrPanel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("right_click"):
			if zone_ref != null:
				zone_ref.unoccupy(self)
			self.queue_free()
			return
		if Input.is_action_just_pressed("left_click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true
		if Input.is_action_pressed("left_click"):
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("left_click"):
			global.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropzone and zone_ref.occupant == self:
				noPos = false
				tween.tween_property(self, "position", zone_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				SoundManager.play("main", "bong")	
			else:
				if (noPos): 
					queue_free()
				else:
					noPos = false
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)

func draw_instruction(instruction):
	var label_text = str(instruction.pc) + " " + Instruction.Type.keys()[instruction.type]
	$InstrPanel.visible = true
	$InstrPanel.set_label(label_text)

func hide_instruction():
	$InstrPanel.visible = false

func _on_mouse_entered():
	if not global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)


func _on_mouse_exited():
	if not global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)


func _on_body_entered(zone):
	if zone.is_in_group("dropzone"):
		if zone.occupy(self) and zone_ref != zone:
			if zone_ref != null:
				zone_ref.unoccupy(self)
			is_inside_dropzone = true
			zone_ref = zone


func _on_body_exited(zone):
	if zone.is_in_group("dropzone"):
		zone.unoccupy(self)
		if zone == zone_ref:
			is_inside_dropzone = false
			
