extends Label

func set_score(score: float):
	text = "Score des devs : " + str(snapped(score, 0.01)) + " IPC"
