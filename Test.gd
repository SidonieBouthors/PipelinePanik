extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var feur = [0,3,4,5]
	for i in range(4) :
		print(feur.pop_at(0))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
