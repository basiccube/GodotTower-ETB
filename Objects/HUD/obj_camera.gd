extends Camera2D

var shake_mag = 0
var shake_mag_acc = 0

var timestop = true

func _process(delta):
	if (global.panic):
		timestop = false
	else:
		timestop = true
	if (global.targetRoom == "timesuproom"):
		timestop = true
	if (global.minutes == 0 && global.seconds == 0 && global.targetRoom != "timesuproom"):
		utils.get_player().state = global.states.timesup
		utils.room_goto("", "timesuproom")
	if (global.seconds < 0):
		global.seconds = 59
		global.minutes -= 1
	if (global.seconds > 59):
		global.minutes += 1
		global.seconds -= 59
	if (global.panic && global.minutes > 1):
		shake_mag = 3
		shake_mag_acc = (5 / 10)
	elif (global.panic && global.minutes <= 1):
		shake_mag = 4
		shake_mag_acc = (6 / 10)
	if (shake_mag > 0):
		shake_mag -= shake_mag_acc
		if (shake_mag_acc == 0):
			shake_mag -= 0.1
		if (shake_mag < 0):
			shake_mag = 0
	if (utils.instance_exists("obj_player") && utils.get_player().state != global.states.timesup && utils.get_player().state != global.states.gameover):
		var target = utils.get_player()
		position.x = target.position.x
		position.y = target.position.y
		if (shake_mag != 0):
			position.y = (target.position.y + utils.randi_range((-shake_mag), shake_mag))
	global_position.x = clamp(global_position.x, (limit_left + 480), (limit_right - 480))
	global_position.y = clamp(global_position.y, (limit_top + 270), (limit_bottom - 270))
	if (shake_mag != 0):
		global_position.y = clamp(global_position.y, (limit_top + 270 + utils.randi_range((-shake_mag), shake_mag)), (limit_bottom - 270 + utils.randi_range((-shake_mag), shake_mag)))
	# Draw code
	$Collect.text = str(global.collect)
	if (!timestop):
		$TimeText.visible = true
		if (global.seconds < 10):
			if (global.minutes < 1):
				$TimeText.add_color_override("font_color", Color(1,0,0))
			else:
				$TimeText.add_color_override("font_color", Color(1,1,1))
			$TimeText.text = str(global.minutes) + ":0" + str(global.seconds)
		elif (global.seconds >= 10):
			if (global.minutes < 1):
				$TimeText.add_color_override("font_color", Color(1,0,0))
			else:
				$TimeText.add_color_override("font_color", Color(1,1,1))
			$TimeText.text = str(global.minutes) + ":" + str(global.seconds)
	else:
		$TimeText.visible = false
	
func _on_Timer_timeout():
	if (!timestop):
		global.seconds -= 1
		if (global.seconds < 0):
			global.seconds = 59
			global.minutes -= 1
	$Timer.start()
