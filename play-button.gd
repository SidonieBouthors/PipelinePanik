extends TextureButton

var playing = false

var play_text = load("res://assets/play-button.png")
var pause_text = load("res://assets/pause-button.png")

var click_mask_image = load("res://assets/button-click-size.png")

func _ready():
	var bitmap = BitMap.new()
	bitmap.create(Vector2i(16, 16))
	bitmap.set_bit_rect(Rect2i(0, 0, 16, 16), true)
	set_click_mask(bitmap)
	
func _pressed():
	playing = !playing
	if (playing):
		texture_normal = pause_text
	else:
		texture_normal = play_text
