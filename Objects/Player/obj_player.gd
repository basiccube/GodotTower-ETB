class_name obj_player
extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
var grav = 0.5
var velocity = Vector2.ZERO

var xscale = 1
var yscale = 1

var movespeed = 0

var targetLevel = ""
var targetRoom = ""

var sprite_index
var flash = false

var input_buffer_jump = 8

var jumpstop = false

var jumpAnim = true
var landAnim = false
var crouchAnim = false
var machslideAnim = true
var machhitAnim = false
var machpunchAnim = false
var facestompAnim = false
var stompAnim = false

var idle = 0
var windingAnim = 0
var dashdust = false

var attacking = false
var slamming = false
var instakillmove = false
var momentum = false
var hurted = false
var throwforce = 0
var superslam = 0
var machfreefall = 0
var ladderbuffer = 0
var toomuchalarm1 = 0

var crouchmask = false

var state = global.states.normal

func _process(delta):
	$Sprite.playing = true
	sprite_index = $Sprite.animation
	$Sprite.material.set_shader_param("flash", flash)
	position.x += velocity.x
	position.y += velocity.y
	$Sprite.scale.x = xscale
	$WallCheck.scale.x = xscale
	$BreakableArea.scale.x = xscale
	if crouchmask:
		$Collision.set_deferred("disabled", true)
		$CrouchCheck.enabled = true
	else:
		$Collision.set_deferred("disabled", false)
		$CrouchCheck.enabled = false
	if (input_buffer_jump < 8):
		input_buffer_jump += 1
	if (hurted):
		modulate.a = 1
	if (state == global.states.mach2
	|| state == global.states.facestomp
	|| state == global.states.machfreefall
	|| state == global.states.machroll
	|| state == global.states.throw
	|| state == global.states.mach3
	|| state == global.states.superslam
	|| state == global.states.slam
	|| state == global.states.shoulder
	|| state == global.states.punch
	|| state == global.states.backkick
	|| state == global.states.uppunch
	|| state == global.states.backbreaker
	|| state == global.states.freefall
	|| state == global.states.Sjump):
		attacking = true
	else:
		attacking = false
	if (state == global.states.mach3
	|| state == global.states.mach4
	|| state == global.states.freefall
	|| state == global.states.slam
	|| state == global.states.superslam
	|| state == global.states.Sjump
	|| state == global.states.machroll
	|| state == global.states.machfreefall
	|| state == global.states.backbreaker):
		instakillmove = true
	else:
		instakillmove = false
	if (flash && $WhiteFlashTimer.is_stopped()):
		$WhiteFlashTimer.wait_time = 0.1
		$WhiteFlashTimer.start()
	if (state != global.states.normal):
		idle = 0
		dashdust = false
	if (state != global.states.mach1 && state != global.states.jump):
		momentum = false
	if (movespeed < 8):
		dashdust = false
	if (state != global.states.grab && state != global.states.throw && state != global.states.shoulder && state != global.states.punch && state != global.states.backkick && state != global.states.uppunch && state != global.states.slam):
		throwforce = 0
	if (state != global.states.facestomp):
		facestompAnim = false
	if (state != global.states.slam):
		slamming = false
	if (state != global.states.freefall && state != global.states.facestomp && state != global.states.superslam && state != global.states.freefallland):
		superslam = 0
	if (state != global.states.mach2):
		machpunchAnim = false
	if (state != global.states.mach2):
		machfreefall = 0
	if (state != global.states.jump):
		ladderbuffer = 0
	if (state != global.states.jump):
		stompAnim = false
	if ((state == global.states.mach3 || state == global.states.machroll || state == global.states.superslam || state == global.states.Sjump || state == global.states.machfreefall) && !utils.instance_exists("obj_mach3effect")):
		toomuchalarm1 = 6
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect.tscn")
	if (toomuchalarm1 > 0):
		toomuchalarm1 -= 1
		if (toomuchalarm1 <= 0 && (state == global.states.mach3 || state == global.states.machroll || state == global.states.Sjump || state == global.states.machfreefall)):
			utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect.tscn")
			toomuchalarm1 = 6
	if (state != global.states.bump && state != global.states.crouch && state != global.states.machroll && state != global.states.hurt && state != global.states.crouchslide && state != global.states.crouchjump):
		crouchmask = false
	else:
		crouchmask = true
	match state:
		global.states.normal:
			scr_player_normal()

func _physics_process(delta):
	var snap_vector = Vector2.ZERO
	if (!Input.is_action_just_pressed("key_jump") && (state != global.states.jump && state != global.states.Sjump && state != global.states.Sjumpprep && state != global.states.bump && state != global.states.crouchjump) && is_on_floor()):
		snap_vector = Vector2.DOWN * 30
	if (state != global.states.gameover):
		if (state != global.states.Sjumpland && state != global.states.gottreasure && state != global.states.keyget && state != global.states.ladder):
			if (velocity.y < 20):
				velocity.y += grav
			velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, 1, false)
			
func is_colliding_with_wall():
	if (($WallCheck.is_colliding() && $WallCheck.get_collider() != null && $WallCheck.get_collider().is_in_group("obj_wall")) ||
	(!crouchmask && $WallCheck/WallCheckTop.is_colliding() && $WallCheck/WallCheckTop.get_collider() != null && $WallCheck/WallCheckTop.get_collider().is_in_group("obj_wall")) ||
	($WallCheck/WallCheckBottom.is_colliding() && $WallCheck/WallCheckBottom.get_collider() != null && $WallCheck/WallCheckBottom.get_collider().is_in_group("obj_wall"))):
		return true
	else:
		return false
			
func get_texture():
	return $Sprite.frames.get_frame($Sprite.animation, $Sprite.frame)
	
func get_frame():
	return $Sprite.frame
	
func is_last_frame():
	if ($Sprite.frame == $Sprite.frames.get_frame_count($Sprite.animation) - 1):
		return true
	else:
		return false
	
func set_animation(anim: String):
	$Sprite.animation = anim
	
func scr_player_normal():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	velocity.x = (move * movespeed)
	if (Input.is_action_pressed("key_dash") && is_on_floor() && !is_colliding_with_wall()):
		jumpAnim = true
		state = global.states.mach1
		movespeed = 0
	if (is_colliding_with_wall() && move != 0):
		movespeed = 0
	jumpstop = false
	if (is_on_floor() && xscale == 1 && move == -1):
		machslideAnim = true
		landAnim = false
		movespeed = 0
	if (is_on_floor() && xscale == -1 && move == 1):
		machslideAnim = true
		landAnim = false
		movespeed = 0
	if (!is_on_floor() && !Input.is_action_just_pressed("key_jump")):
		jumpAnim = false
		state = global.states.jump
		machslideAnim = true
	if (Input.is_action_just_pressed("key_jump") && is_on_floor() && Input.is_action_pressed("key_up") && !Input.is_action_pressed("key_down") && !Input.is_action_pressed("key_dash") && move == 0):
		velocity.y = -12
		state = global.states.highjump
		machslideAnim = true
		jumpAnim = true
		utils.playsound("Jump")
	if (Input.is_action_just_pressed("key_jump") && is_on_floor() && !Input.is_action_pressed("key_down") && $Sprite.animation != "Sjumpprep" && input_buffer_jump >= 8):
		velocity.y = -9
		state = global.states.jump
		machslideAnim = true
		jumpAnim = true
		utils.playsound("Jump")
	if (is_on_floor() && input_buffer_jump < 8 && !Input.is_action_pressed("key_down") && velocity.y >= 0):
		stompAnim = false
		velocity.y = -9
		state = global.states.jump
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Jump")
	if ((Input.is_action_pressed("key_down") && is_on_floor()) || ($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("collision"))):
		state = global.states.crouch
		machslideAnim = true
		landAnim = false
		crouchAnim = true
		idle = 0
	if (move != 0):
		if (movespeed < 6 && $Sprite.animation != "running"):
			movespeed += 0.5
		elif (movespeed == 5 && $Sprite.animation != "running"):
			movespeed = 6
		elif (movespeed < 8 && $Sprite.animation == "running"):
			movespeed += 0.2
		elif (movespeed == 8 && $Sprite.animation == "running"):
			movespeed = 9
	else:
		movespeed = 0
	if (movespeed > 6):
		movespeed -= 0.1
	if (Input.is_action_pressed("key_up") && move == 0):
		landAnim = false
		$Sprite.animation = "Sjumpprep"
		if ($Sprite.frame == 5):
			$Sprite.speed_scale = 0
	if (!(Input.is_action_pressed("key_up") && move == 0)):
		if (machslideAnim && !landAnim):
			if (move == 0):
				if (idle < 400):
					idle += 1
				if (idle >= 300 && is_last_frame()):
					idle = 0
				if (idle >= 300 && $Sprite.animation != "idlefrown" && $Sprite.animation != "idledance" && $Sprite.animation != "idlevomit" && $Sprite.animation != "idlevomitblood"):
					randomize()
					var idleanim = utils.randi_range(0, 100)
					if (idleanim < 40):
						$Sprite.animation = "idlefrown"
					if (idleanim < 80 && idleanim >= 40):
						$Sprite.animation = "idledance"
					if (idleanim < 99 && idleanim >= 80):
						$Sprite.animation = "idlevomit"
					if (idleanim < 100 && idleanim >= 99):
						$Sprite.animation = "idlevomitblood"
				if (idle < 300):
					if (windingAnim < 50):
						movespeed = 0
						$Sprite.animation = "idle"
					else:
						idle = 0
						windingAnim -= 1
						$Sprite.animation = "winding"
			if (move != 0):
				idle = 0
				machslideAnim = true
				$Sprite.animation = "move"
			if (move != 0):
				xscale = move
		if (landAnim):
			if (move == 0):
				movespeed = 0
				$Sprite.animation = "land"
				if ($Sprite.frame == 5):
					landAnim = false
			if (move != 0):
				$Sprite.animation = "land2"
				if ($Sprite.frame == 4):
					landAnim = false
					$Sprite.animation = "move"
		if (!machslideAnim && !machhitAnim):
			$Sprite.animation = "machslideend"
			if ($Sprite.frame == 5):
				machslideAnim = true
		if (machhitAnim):
			machhitAnim = false
			machslideAnim = true
		if (move != 0):
			if (movespeed < 3):
				$Sprite.speed_scale = 0.35
			elif (movespeed > 3 && movespeed < 6):
				$Sprite.speed_scale = 0.45
			else:
				$Sprite.speed_scale = 0.6
		else:
			$Sprite.speed_scale = 0.35
	if (!utils.instance_exists("obj_cloudeffect") && is_on_floor() && move != 0 && ($Sprite.frame == 4 || $Sprite.frame == 10)):
		utils.instance_create(position.x, position.y + 43, "res://Objects/Visuals/Effects/obj_cloudeffect.tscn")
	if (movespeed == 9 && !dashdust):
		dashdust = true
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_jumpdust.tscn")

func scr_playersounds():
	if ((state == global.states.normal || (state == global.states.grabbing && is_on_floor())) && velocity.x != 0 && !utils.soundplaying("Footsteps")):
		utils.playsound("Footsteps")
	if (state != global.states.normal && state != global.states.grabbing):
		utils.stopsound("Footsteps")

func _on_WhiteFlashTimer_timeout():
	flash = false
