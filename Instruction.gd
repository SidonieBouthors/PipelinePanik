extends Node
class_name Instruction
var pc: int
var type: Type
var inputs: Array # Array of type Register or int (immediate values)
var output: Register

enum Type {
	ALU,
	MEM,
	BRANCH
}

enum Register {
	r0 = 2 ** 17,
	r1,
	r2,
	r3,
	r4,
	r5,
	r6,
	r7,
}

func _init(_pc: int, _type: Type, _inputs: Array, _output: Register):
	pc = _pc
	type = _type
	inputs = _inputs
	output = _output

func get_text():
	var ins = ""
	for inp in inputs:
		if inp in Register.values():
			ins += Register.keys()[inp - Register.r0] + " "
		else:
			ins += str(inp) + " "
	var text = str(pc) + " " + Type.keys()[type] + " " + Register.keys()[output - Register.r0] + " " + ins
	return text
