extends Node
class_name Instruction
var pc : int
var type : Type
var inputs : Array #Array of type Register or int (immediate values)
var output : Register

enum Type {
	ALU,
	MEM,
	BRANCH,
	NOP
} 

enum Register {
	r0,
	r1,
	r2,
	r3,
	r4,
	r5,
	r6,
	r7
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
