extends Node2D

func _ready():
	$Sprite.texture = utils.get_player().get_texture()
	modulate.a = 0.8
	$DestroyTimer.start()
	scale.x = utils.get_player().xscale
	randomize()
	var randcolor = utils.randi_range(0, 2)
	if (randcolor == 0):
		modulate.r = 1
		modulate.g = 0
		modulate.b = 0
	elif (randcolor == 1):
		modulate.r = 0.33
		modulate.g = 1
		modulate.b = 0
	elif (randcolor == 2):
		modulate.r = 0.25
		modulate.g = 0.33
		modulate.b = 1
	$AlphaOffTimer.start()
	
func _process(delta):
	position.x += 10

func _on_DestroyTimer_timeout():
	queue_free()

func _on_AlphaOffTimer_timeout():
	modulate.a = 0
	$AlphaOnTimer.start()

func _on_AlphaOnTimer_timeout():
	modulate.a = 0.8
	$AlphaOffTimer.start()
