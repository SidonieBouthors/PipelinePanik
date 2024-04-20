extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var feur = [0,3,4,5]
	for i in range(4) :
		print(feur.pop_at(0))
	
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(1)
	timer.set_one_shot(true)
	timer.timeout.connect(on_timer_timeout)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_timer_timeout():
	print("Timer timeout")
