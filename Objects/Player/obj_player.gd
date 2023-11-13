class_name obj_player
extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
var grav = 0.5
var velocity = Vector2.ZERO

var xscale = 1
var yscale = 1

var movespeed = 0
var mach2 = 0

var targetLevel = ""
var targetRoom = ""

var combo = 0

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

var bounce = false
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

onready var sprite = $Sprite

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
	else:
		$Collision.set_deferred("disabled", false)
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
	scr_playersounds()
	match state:
		global.states.normal:
			scr_player_normal()
		global.states.jump:
			scr_player_jump()
		global.states.highjump:
			scr_player_highjump()
		global.states.crouch:
			scr_player_crouch()
		global.states.crouchjump:
			scr_player_crouchjump()
		global.states.facestomp:
			scr_player_facestomp()
		global.states.freefall:
			scr_player_freefall()
		global.states.freefallland:
			scr_player_freefallland()
		global.states.superslam:
			scr_player_superslam()
		global.states.machfreefall:
			scr_player_machfreefall()

func _physics_process(delta):
	var snap_vector = Vector2.ZERO
	if (!Input.is_action_just_pressed("key_jump") && (state != global.states.jump && state != global.states.highjump && state != global.states.Sjump && state != global.states.Sjumpprep && state != global.states.bump && state != global.states.crouchjump) && is_on_floor()):
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
	if ((Input.is_action_pressed("key_down") && is_on_floor()) || ($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("solid"))):
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
		
func scr_player_jump():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	if (!momentum):
		velocity.x = (move * movespeed)
	else:
		velocity.x = (xscale * movespeed)
	if (move == 0 && !momentum):
		movespeed = 0
	if (move != 0 && movespeed < 6):
		movespeed += 0.5
	if (is_colliding_with_wall()):
		movespeed = 0
	if (xscale == 1 && move == -1):
		mach2 = 0
		movespeed = 0
		momentum = false
	if (xscale == -1 && move == 1):
		mach2 = 0
		movespeed = 0
		momentum = false
	if (Input.is_action_just_pressed("key_down")):
		if (velocity.y < 0.5):
			velocity.y /= 2
		state = global.states.facestomp
	landAnim = true
	if (!Input.is_action_pressed("key_jump") && !jumpstop && velocity.y < 0.5 && !stompAnim):
		velocity.y /= 2
		jumpstop = true
	if (ladderbuffer > 0):
		ladderbuffer -= 1
	if (is_on_ceiling() && !jumpstop && jumpAnim):
		velocity.y = grav
		jumpstop = true
	if (is_on_floor() && velocity.y >= 0 && Input.is_action_pressed("key_dash") && momentum):
		landAnim = false
		state = global.states.mach1
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	if (is_on_floor() && velocity.y >= 0 && (!Input.is_action_pressed("key_dash") || !momentum)):
		if (Input.is_action_pressed("key_dash")):
			landAnim = false
		state = global.states.normal
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	if (is_on_floor() && input_buffer_jump < 8 && !Input.is_action_pressed("key_down") && velocity.y >= 0):
		stompAnim = false
		velocity.y = -9
		state = global.states.jump
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Jump")
	if (Input.is_action_just_pressed("key_jump")):
		input_buffer_jump = 0
	if (!stompAnim):
		if (jumpAnim):
			if (momentum):
				$Sprite.animation = "jump2"
			else:
				$Sprite.animation = "jump"
			if ($Sprite.frame == 8):
				jumpAnim = false
		if (!jumpAnim):
			if (momentum):
				$Sprite.animation = "fall2"
			else:
				$Sprite.animation = "fall"
	if (stompAnim):
		if ($Sprite.animation == "stompprep" && $Sprite.frame == 4):
			$Sprite.animation = "stomp"
	if (move != 0):
		xscale = move
	$Sprite.speed_scale = 0.35
	
func scr_player_highjump():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	velocity.x = (move * movespeed)
	if (move == 0):
		movespeed = 0
	if (move != 0 && movespeed < 5):
		movespeed += 0.5
	if (is_colliding_with_wall()):
		movespeed = 0
	if (xscale == 1 && move == -1):
		movespeed = 0
	if (xscale == -1 && move == 1):
		movespeed = 0
	if (Input.is_action_just_pressed("key_down")):
		if (velocity.y < 0.5):
			velocity.y /= 2
		state = global.states.facestomp
	landAnim = true
	if (!Input.is_action_pressed("key_jump") && !jumpstop && velocity.y < 0.5 && !stompAnim):
		velocity.y /= 2
		jumpstop = true
	if (ladderbuffer > 0):
		ladderbuffer -= 1
	if (is_on_ceiling() && !jumpstop && jumpAnim):
		velocity.y = grav
		jumpstop = true
	if (is_on_floor() && velocity.y >= 0):
		if (Input.is_action_pressed("key_dash")):
			landAnim = false
		state = global.states.normal
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	if (is_on_floor() && input_buffer_jump < 8 && !Input.is_action_pressed("key_down") && velocity.y >= 0):
		velocity.y = -9
		state = global.states.jump
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Jump")
	if (Input.is_action_just_pressed("key_jump")):
		input_buffer_jump = 0
	if (jumpAnim):
		$Sprite.animation = "Sjumpstart"
		if ($Sprite.frame == 3):
			jumpAnim = false
	if (!jumpAnim):
		$Sprite.animation = "Sjump"
	if (move != 0):
		xscale = move
	$Sprite.speed_scale = 0.35
	
func scr_player_crouch():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	velocity.x = (move * movespeed)
	crouchmask = true
	if (is_colliding_with_wall()):
		movespeed = 0
	if (xscale == 1 && move == -1):
		movespeed = 0
	if (xscale == -1 && move == 1):
		movespeed = 0
	if (!is_on_floor() && !Input.is_action_just_pressed("key_jump")):
		jumpAnim = false
		state = global.states.crouchjump
		movespeed = 4
		crouchAnim = true
	if (Input.is_action_just_pressed("key_jump") && is_on_floor() && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("solid"))):
		velocity.y = -9.2
		state = global.states.crouchjump
		movespeed = 4
		crouchAnim = true
		jumpAnim = true
		utils.playsound("Jump")
	if (is_on_floor() && !Input.is_action_pressed("key_down") && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("solid")) && !Input.is_action_just_pressed("key_jump")):
		state = global.states.normal
		movespeed = 0
		crouchAnim = true
		jumpAnim = true
		crouchmask = false
	if (movespeed < 4):
		movespeed += 0.5
	elif (movespeed >= 4):
		movespeed = 4
	if (!crouchAnim):
		if (move == 0):
			$Sprite.animation = "crouch"
		if (move != 0):
			$Sprite.animation = "crawl"
	if (crouchAnim):
		$Sprite.animation = "crouchstart"
		if ($Sprite.frame == 2):
			crouchAnim = false
	if (move != 0):
		xscale = move
		crouchAnim = false
	$Sprite.speed_scale = 0.6
	
func scr_player_crouchjump():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	velocity.x = (move * movespeed)
	crouchmask = true
	if (xscale == 1 && move == -1):
		movespeed = 0
	if (xscale == -1 && move == 1):
		movespeed = 0
	if (movespeed < 4):
		movespeed += 0.5
	elif (movespeed >= 4):
		movespeed = 4
	if (!Input.is_action_pressed("key_jump") && !jumpstop && jumpAnim):
		velocity.y /= 2
		jumpstop = true
	if (is_on_ceiling() && !jumpstop && jumpAnim):
		velocity.y = grav
		jumpstop = true
	if (is_on_floor() && Input.is_action_pressed("key_down")):
		state = global.states.crouch
		jumpAnim = true
		crouchAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	if (is_on_floor() && !Input.is_action_pressed("key_down") && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("solid")) && !Input.is_action_just_pressed("key_jump")):
		state = global.states.normal
		crouchAnim = true
		landAnim = true
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		crouchmask = false
	if (jumpAnim):
		$Sprite.animation = "crouchjump"
		if ($Sprite.frame == 8):
			jumpAnim = false
	if (!jumpAnim):
		$Sprite.animation = "crouchfall"
	if (move != 0):
		xscale = move
	$Sprite.speed_scale = 0.35
	
func scr_player_facestomp():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	jumpAnim = false
	velocity.x = (move * movespeed)
	if (is_colliding_with_wall()):
		movespeed = 0
	if (move == 0):
		movespeed = 0
	if (move != 0 && movespeed < 6):
		movespeed += 0.5
	if (xscale == 1 && move == -1):
		movespeed = 0
	if (xscale == -1 && move == 1):
		movespeed = 0
	if (!Input.is_action_pressed("key_down")):
		state = global.states.jump
	landAnim = true
	if (velocity.y > 0):
		superslam += 1
	else:
		superslam = 0
	if (velocity.y > 15):
		state = global.states.freefall
		superslam = 0
	if (is_on_floor() && velocity.y >= 0):
		utils.playsound("Facestomp")
		state = global.states.freefallland
		jumpAnim = true
		jumpstop = false
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	if (!facestompAnim):
		$Sprite.animation = "facestomp"
	elif (facestompAnim):
		$Sprite.animation = "facestomphit"
		if ($Sprite.frame == 5):
			facestompAnim = false
	if (move != 0):
		xscale = move
	$Sprite.speed_scale = 0.35
	
func scr_player_freefall():
	movespeed = 0
	velocity.x = 0
	landAnim = true
	if (Input.is_action_pressed("key_dash")):
		state = global.states.mach2
		velocity.y = 0
		mach2 = 35
	if (velocity.y > 0):
		superslam += 1
	else:
		superslam = 0
	if (superslam > 30):
		state = global.states.superslam
	if (is_on_floor()):
		state = global.states.freefallland
		jumpAnim = true
		jumpstop = false
		for i in get_tree().get_nodes_in_group("obj_baddie"):
			if (i.is_on_floor() && i.screenvisible):
				i.velocity.y = -7
				i.velocity.x = 0
		for i in get_tree().get_nodes_in_group("obj_camera"):
			i.shake_mag = 10
			i.shake_mag_acc = (30 / 30)
		combo = 0
		bounce = false
		var effectid = utils.instance_create(position.x, position.y + 35, "res://Objects/Visuals/Effects/obj_bangeffect.tscn")
		effectid.scale.x = xscale
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	$Sprite.animation = "freefall"
	$Sprite.speed_scale = 0.35
	
func scr_player_freefallland():
	mach2 = 0
	jumpAnim = true
	landAnim = false
	machslideAnim = true
	crouchAnim = false
	machhitAnim = false
	movespeed = 0
	velocity.x = 0
	velocity.y = 0
	$Sprite.animation = "freefallland"
	if ($Sprite.frame == 6 && !(superslam > 30)):
		state = global.states.normal
	if ($Sprite.frame == 6 && superslam > 30):
		state = global.states.machfreefall
		velocity.y = -7
		
func scr_player_superslam():
	movespeed = 0
	velocity.x = 0
	mach2 = 0
	if (is_on_floor()):
		utils.playsound("SuperImpact")
		state = global.states.freefallland
		jumpAnim = true
		jumpstop = false
		for i in get_tree().get_nodes_in_group("obj_baddie"):
			if (i.is_on_floor() && i.screenvisible):
				i.state = global.states.stun
				i.velocity.y = -7
				i.velocity.x = 0
				i.stunned = 200
		for i in get_tree().get_nodes_in_group("obj_camera"):
			i.shake_mag = 20
			i.shake_mag_acc = (40 / 30)
		velocity.x = 0
		$Sprite.speed_scale = 0.35
		bounce = false
		var effectid = utils.instance_create(position.x, position.y + 35, "res://Objects/Visuals/Effects/obj_bangeffect.tscn")
		effectid.scale.x = xscale
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
	jumpAnim = true
	landAnim = false
	machslideAnim = true
	crouchAnim = true
	if (!utils.instance_exists("obj_superslameffect")):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_superslameffect.tscn")
	$Sprite.animation = "freefall"
	$Sprite.speed_scale = 0.35
		
func scr_player_machfreefall():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	if (mach2 == 0):
		velocity.x = (move * movespeed)
		movespeed = 4
	else:
		velocity.x = (xscale * movespeed)
		movespeed = 10
	machslideAnim = true
	if (is_colliding_with_wall()):
		machhitAnim = false
		state = global.states.bump
		velocity.x = 2.5 * (-xscale)
		velocity.y = -2.5
		mach2 = 0
		utils.instance_create(position.x + 10, position.y + 10, "res://Objects/Visuals/Effects/obj_bumpeffect.tscn")
		utils.playsound("Bump")
	if (is_on_floor()):
		bounce = false
		jumpstop = false
		var effectid = utils.instance_create(position.x, position.y + 35, "res://Objects/Visuals/Effects/obj_bangeffect.tscn")
		effectid.scale.x = xscale
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_landcloud.tscn")
		utils.playsound("Land")
		for i in get_tree().get_nodes_in_group("obj_baddie"):
			if (i.is_on_floor() && i.screenvisible):
				i.state = global.states.stun
				i.velocity.y = -7
				i.velocity.x = 0
				i.stunned = 200
		for i in get_tree().get_nodes_in_group("obj_camera"):
			i.shake_mag = 20
			i.shake_mag_acc = (40 / 30)
		state = global.states.freefallland
	if (!utils.soundplaying("Mach2")):
		utils.playsound("Mach2")
	$Sprite.animation = "machfreefall"
	$Sprite.speed_scale = 0.5

func scr_playersounds():
	if ((state == global.states.normal || (state == global.states.grabbing && is_on_floor())) && velocity.x != 0 && !utils.soundplaying("Footsteps")):
		utils.playsound("Footsteps")
	if (((state != global.states.normal && state != global.states.grabbing) || state == global.states.normal && velocity.x == 0) && utils.soundplaying("Footsteps")):
		utils.stopsound("Footsteps")

func _on_WhiteFlashTimer_timeout():
	flash = false
