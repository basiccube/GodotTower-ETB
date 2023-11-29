extends Node2D

var roomname = ""
var music
onready var musicnode = $music

# This array is arranged the following way:
#   room name      song name
var room_arr = [
	["test_room", "music_tutorial"],
	["tutorial_room1", "music_tutorial"],
	["normalT_room1", "music_onepizzaatatime"]
]

func room_start():
	if (!global.panic):
		for i in room_arr.size():
			var b = room_arr[i]
			if (global.targetRoom == b[0]):
				var prevmusic = music
				var oldmusicpos = $music.get_playback_position()
				music = b[1]
				if (music != prevmusic):
					var newmusic = load("res://Music/" + music + ".ogg")
					$music.stream = newmusic
					$music.play()
				$RestartMusicTimer.start()
	if (global.targetRoom == "timesuproom"):
		$music.stop()
		$timesupmusic.play()
	if (global.targetRoom == "rank_room"):
		$music.stop()
		$victorymusic.play()
		
func _process(delta):
	var obj_player = utils.get_player()
	if ((obj_player.state == global.states.knightpep || obj_player.state == global.states.knightpepattack) && !$knightmusic.playing):
		$music.stream_paused = true
		$knightmusic.play()
	elif (obj_player.state == global.states.bombpep && obj_player.sprite_index != "bombpep_end" && !$bombmusic.playing):
		$music.stream_paused = true
		$bombmusic.play()
	elif ("bonus" in global.targetRoom && !$scarymusic.playing):
		$music.stream_paused = true
		$scarymusic.play()
	elif ("treasure" in global.targetRoom):
		$music.stream_paused = true
	elif (obj_player.state == global.states.keyget):
		$music.stream_paused = true
	else:
		$music.stream_paused = false
		$knightmusic.stop()
		$bombmusic.stop()
	if (global.panic && music != "music_escapetheme"):
		music = "music_escapetheme"
		var newmusic = load("res://Music/" + music + ".ogg")
		$music.stream = newmusic
		$music.play()

func _on_RestartMusicTimer_timeout():
	if (!$music.playing):
		$music.play()
