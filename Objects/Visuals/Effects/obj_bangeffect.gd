extends Node2D

func _ready():
	var rng = utils.randi_range(1, 5)
	if (rng == 1):
		utils.playsound("Punch1")
	elif (rng == 2):
		utils.playsound("Punch2")
	elif (rng == 3):
		utils.playsound("Punch3")
	elif (rng == 4):
		utils.playsound("Punch4")
	elif (rng == 5):
		utils.playsound("Punch5")
	$Sprite.playing = true
	$Sprite.speed_scale = 0.5

func _on_Sprite_animation_finished():
	queue_free()
