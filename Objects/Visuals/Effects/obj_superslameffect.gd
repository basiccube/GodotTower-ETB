extends Node2D

func _ready():
	$Sprite.playing = true
	$Sprite.speed_scale = 0.35
	
func _process(delta):
	var obj_player = utils.get_player()
	position.x = obj_player.position.x
	position.y = obj_player.position.y
	if (obj_player.state != global.states.superslam || obj_player.sprite.frame == 4):
		queue_free()
