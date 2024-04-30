extends Node
class_name Instruction
var pc : int
var type : Type
var inputs : Array #Array of type Register or int (immediate values)
var output : Register

enum Type {
	ALU,
	MEM,
	BRANCH
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

func get_text():
	var ins = ""
	for inp in inputs:
		ins += str(inp) + " "
	var text = Type.keys()[type] + " " + Register.keys()[output] + " " + ins
	print(text)
	return text
