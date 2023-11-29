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
var punch = 0

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
	if (state != global.states.grab
	&& state != global.states.throw
	&& state != global.states.shoulder
	&& state != global.states.punch
	&& state != global.states.backkick
	&& state != global.states.uppunch
	&& state != global.states.slam):
		throwforce = 0
	if (state != global.states.facestomp):
		facestompAnim = false
	if (state != global.states.slam):
		slamming = false
	if (state != global.states.freefall
	&& state != global.states.facestomp
	&& state != global.states.superslam
	&& state != global.states.freefallland):
		superslam = 0
	if (state != global.states.mach2):
		machpunchAnim = false
	if (state != global.states.mach2):
		machfreefall = 0
	if (state != global.states.jump):
		ladderbuffer = 0
	if (state != global.states.jump):
		stompAnim = false
	if ((state == global.states.mach3
	|| state == global.states.machroll
	|| state == global.states.superslam
	|| state == global.states.Sjump
	|| state == global.states.machfreefall) && !utils.instance_exists("obj_mach3effect")):
		toomuchalarm1 = 6
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect.tscn")
	if (toomuchalarm1 > 0):
		toomuchalarm1 -= 1
		if (toomuchalarm1 <= 0 && (state == global.states.mach3
		|| state == global.states.machroll
		|| state == global.states.Sjump
		|| state == global.states.machfreefall)):
			utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect.tscn")
			utils.instance_create(position.x - (75 * xscale), position.y, "res://Objects/Visuals/Effects/obj_mach3effect.tscn")
			toomuchalarm1 = 6
	if (state != global.states.bump
	&& state != global.states.crouch
	&& state != global.states.machroll
	&& state != global.states.hurt
	&& state != global.states.crouchslide
	&& state != global.states.crouchjump):
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
		global.states.crouchslide:
			scr_player_crouchslide()
		global.states.facestomp:
			scr_player_facestomp()
		global.states.freefall:
			scr_player_freefall()
		global.states.freefallland:
			scr_player_freefallland()
		global.states.freefallprep:
			scr_player_freefallprep()
		global.states.superslam:
			scr_player_superslam()
		global.states.machfreefall:
			scr_player_machfreefall()
		global.states.mach1:
			scr_player_mach1()
		global.states.mach2:
			scr_player_mach2()
		global.states.mach3:
			scr_player_mach3()
		global.states.machroll:
			scr_player_machroll()
		global.states.machslide:
			scr_player_machslide()
		global.states.bump:
			scr_player_bump()
		global.states.Sjump:
			scr_player_Sjump()
		global.states.Sjumpland:
			scr_player_Sjumpland()
		global.states.Sjumpprep:
			scr_player_Sjumpprep()

func _physics_process(delta):
	var snap_vector = Vector2.ZERO
	if (!Input.is_action_pressed("key_jump")
	&& (state != global.states.jump
	&& state != global.states.highjump
	&& state != global.states.Sjump
	&& state != global.states.Sjumpprep
	&& state != global.states.bump
	&& state != global.states.crouchjump) && is_on_floor()):
		snap_vector = Vector2.DOWN * 20
	if (state != global.states.gameover
	&& state != global.states.Sjumpland
	&& state != global.states.gottreasure
	&& state != global.states.keyget
	&& state != global.states.ladder):
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
	if ((Input.is_action_pressed("key_down") && is_on_floor()) || ($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("obj_wall"))):
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
	if (Input.is_action_just_pressed("key_jump") && is_on_floor() && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("obj_wall"))):
		velocity.y = -9.2
		state = global.states.crouchjump
		movespeed = 4
		crouchAnim = true
		jumpAnim = true
		utils.playsound("Jump")
	if (is_on_floor() && !Input.is_action_pressed("key_down") && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("obj_wall")) && !Input.is_action_just_pressed("key_jump")):
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
	if (is_on_floor() && !Input.is_action_pressed("key_down") && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("obj_wall")) && !Input.is_action_just_pressed("key_jump")):
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
	
func scr_player_crouchslide():
	velocity.x = (xscale * movespeed)
	if (movespeed >= 0):
		movespeed -= 0.2
	crouchmask = true
	if (mach2 >= 35 && !Input.is_action_pressed("key_down") && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("obj_wall")) && Input.is_action_pressed("key_dash")):
		machhitAnim = true
		state = global.states.mach2
	if (velocity.x == 0 || movespeed <= 0):
		state = global.states.crouch
		movespeed = 0
		mach2 = 0
		crouchAnim = true
	if (is_colliding_with_wall()):
		machhitAnim = false
		machslideAnim = true
		movespeed = 0
		$Sprite.frame = 0
		state = global.states.bump
		velocity.x = 2.5 * (-xscale)
		velocity.y = -3
		mach2 = 0
		utils.instance_create(position.x + 10, position.y + 10, "res://Objects/Visuals/Effects/obj_bumpeffect.tscn")
		utils.playsound("Bump")
	$Sprite.animation = "crouchslip"
	if (!utils.instance_exists("obj_slidecloud") && is_on_floor() && movespeed > 5):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_slidecloud.tscn")
	
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
		
func scr_player_freefallprep():
	jumpAnim = true
	landAnim = false
	machslideAnim = true
	crouchAnim = true
	if (is_last_frame()):
		state = global.states.mach2
	$Sprite.animation = "mach2jump"
	$Sprite.speed_scale = 0.35
	utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect.tscn")
		
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
		$Sprite.frame = 0
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
	
func scr_player_mach1():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	landAnim = false
	if (is_colliding_with_wall()):
		mach2 = 0
		state = global.states.normal
		movespeed = 0
	if (movespeed <= 8):
		movespeed += 0.2
	machhitAnim = false
	velocity.x = floor(xscale * movespeed)
	if (is_on_floor() && xscale == 1 && move == -1):
		momentum = false
		mach2 = 0
		movespeed = 0
		xscale = -1
	if (is_on_floor() && xscale == -1 && move == 1):
		momentum = false
		mach2 = 0
		movespeed = 0
		xscale = 1
	if (Input.is_action_just_pressed("key_jump") && is_on_floor() && Input.is_action_pressed("key_dash")):
		momentum = true
		velocity.y = -9
		state = global.states.jump
		jumpAnim = true
	if (is_on_floor()):
		if (mach2 < 35):
			mach2 += 1
		if (mach2 >= 35):
			utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_jumpdust.tscn")
			state = global.states.mach2
	if (!is_on_floor()):
		momentum = true
		state = global.states.jump
		jumpAnim = false
	if (!Input.is_action_pressed("key_dash") && is_on_floor()):
		state = global.states.normal
		mach2 = 0
		machslideAnim = true
	if (Input.is_action_pressed("key_down")):
		utils.playsound("Slide")
		state = global.states.crouchslide
		mach2 = 0
	if (!momentum):
		$Sprite.animation = "mach1"
	else:
		$Sprite.animation = "running"
	if (movespeed < 4):
		$Sprite.speed_scale = 0.35
	elif (movespeed > 4 && movespeed < 8):
		$Sprite.speed_scale = 0.45
	else:
		$Sprite.speed_scale = 0.6
	if (!utils.instance_exists("obj_dashcloud") && is_on_floor()):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_dashcloud.tscn")
		
func scr_player_mach2():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	if (windingAnim < 200):
		windingAnim += 1
	velocity.x = (xscale * movespeed)
	machslideAnim = true
	movespeed = 10
	if (!is_on_floor() && velocity.y >= 0):
		machfreefall += 1
		if (machfreefall > 30):
			state = global.states.machfreefall
	else:
		machfreefall = 0
	if (!is_on_floor()):
		if (xscale == 1 && move == -1):
			movespeed = 8
		if (xscale == -1 && move == 1):
			movespeed = 8
	if (is_on_floor()):
		if (mach2 < 100):
			mach2 += 1
		if (mach2 >= 100):
			machhitAnim = false
			flash = true
			$Sprite.animation = "mach4"
			utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_jumpdust.tscn")
			utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect1.tscn")
			utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_mach3effect2.tscn")
			movespeed = 8
			state = global.states.mach3
	if (!Input.is_action_pressed("key_dash") && is_on_floor()):
		utils.playsound("Slide")
		state = global.states.machslide
		mach2 = 35
	if (move == -1 && xscale == 1 && is_on_floor()):
		utils.playsound("Slide")
		state = global.states.machslide
		mach2 = 35
	if (move == 1 && xscale == -1 && is_on_floor()):
		utils.playsound("Slide")
		state = global.states.machslide
		mach2 = 35
	if (Input.is_action_pressed("key_down") && is_on_floor()):
		utils.playsound("Slide")
		machhitAnim = false
		state = global.states.crouchslide
	if (!Input.is_action_pressed("key_jump") && !jumpstop && velocity.y < 0.5 && !stompAnim):
		velocity.y /= 2
		jumpstop = true
	if (is_on_floor() && velocity.y >= 0):
		jumpstop = false
	if (input_buffer_jump < 8 && is_on_floor() && !(move == 1 && xscale == -1) && !(move == -1 && xscale == 1) && Input.is_action_pressed("key_dash")):
		velocity.y = -9
	if (is_colliding_with_wall()):
		machhitAnim = false
		$Sprite.frame = 0
		state = global.states.bump
		velocity.x = 2.5 * (-xscale)
		velocity.y = -3
		mach2 = 0
		utils.instance_create(position.x + 10, position.y + 10, "res://Objects/Visuals/Effects/obj_bumpeffect.tscn")
		utils.playsound("Bump")
	if (is_on_floor()):
		if (!machpunchAnim):
			if (!machhitAnim):
				$Sprite.animation = "mach"
			else:
				$Sprite.animation = "machhit"
		else:
			if (punch == 0):
				$Sprite.animation = "machpunch1"
			if (punch == 1):
				$Sprite.animation = "machpunch2"
			if (is_last_frame() && $Sprite.animation == "machpunch1"):
				punch = 1
				machpunchAnim = false
			if (is_last_frame() && $Sprite.animation == "machpunch2"):
				punch = 0
				machpunchAnim = false
	else:
		$Sprite.animation = "mach2jump"
	if (Input.is_action_just_pressed("key_jump")):
		input_buffer_jump = 0
	if (!is_on_floor()):
		machpunchAnim = false
	if (!utils.instance_exists("obj_dashcloud") && is_on_floor()):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_dashcloud.tscn")
	$Sprite.speed_scale = 0.6
	
func scr_player_mach3():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	if (windingAnim < 200):
		windingAnim += 1
	velocity.x = (xscale * movespeed)
	mach2 = 100
	machslideAnim = true
	movespeed = 14
	if (Input.is_action_pressed("key_down") && is_on_floor()):
		machhitAnim = false
		state = global.states.crouchslide
	if (Input.is_action_just_pressed("key_jump")):
		input_buffer_jump = 0
	if (!Input.is_action_pressed("key_dash") && is_on_floor()):
		flash = false
		utils.playsound("Slide")
		state = global.states.machslide
		mach2 = 35
	if (move == -1 && xscale == 1 && is_on_floor()):
		flash = false
		utils.playsound("Slide")
		state = global.states.machslide
		mach2 = 35
	if (move == 1 && xscale == -1 && is_on_floor()):
		flash = false
		utils.playsound("Slide")
		state = global.states.machslide
		mach2 = 35
	if (!Input.is_action_pressed("key_jump") && !jumpstop && velocity.y < 0.5 && !stompAnim):
		velocity.y /= 2
		jumpstop = true
	if (is_on_floor() && velocity.y >= 0):
		jumpstop = false
	if (input_buffer_jump < 8 && is_on_floor() && !(move == 1 && xscale == -1) && !(move == -1 && xscale == 1) && Input.is_action_pressed("key_dash")):
		velocity.y = -9
	if (Input.is_action_pressed("key_up")):
		utils.playsound("SuperMove")
		velocity.y = -4
		$Sprite.animation = "superjumpprep"
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_machsuperjump1.tscn")
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_machsuperjump2.tscn")
		state = global.states.Sjumpprep
		velocity.x = 0
		flash = true
	if (Input.is_action_pressed("key_down") && is_on_floor()):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_jumpdust.tscn")
		flash = false
		state = global.states.machroll
	if (is_colliding_with_wall()):
		state = global.states.bump
		utils.playsound("SuperImpact")
		for i in get_tree().get_nodes_in_group("obj_baddie"):
			if (i.is_on_floor() && i.screenvisible):
				i.state = global.states.stun
				i.velocity.y = -7
				i.velocity.x = 0
				i.stunned = 200
		for i in get_tree().get_nodes_in_group("obj_camera"):
			i.shake_mag = 20
			i.shake_mag_acc = (40 / 30)
		$Sprite.frame = 0
		$Sprite.speed_scale = 0.35
		flash = false
		combo = 0
		velocity.x = 2.5 * (-xscale)
		velocity.y = -3
		mach2 = 0
		utils.instance_create(position.x + 10, position.y + 10, "res://Objects/Visuals/Effects/obj_bumpeffect.tscn")
		utils.playsound("Bump")
	$Sprite.animation = "mach4"
	if (!utils.instance_exists("obj_chargeeffect")):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_chargeeffect.tscn")
	if (!utils.instance_exists("obj_dashcloud") && is_on_floor()):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_dashcloud.tscn")
	$Sprite.speed_scale = 0.6
	
func scr_player_machroll():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	velocity.x = (xscale * movespeed)
	mach2 = 100
	machslideAnim = true
	movespeed = 12
	if ((!is_on_floor()) || (!Input.is_action_pressed("key_down") && !($CrouchCheck.is_colliding() && $CrouchCheck.get_collider() != null && $CrouchCheck.get_collider().is_in_group("obj_wall")))):
		machhitAnim = true
		state = global.states.mach2
	if (is_colliding_with_wall()):
		state = global.states.bump
		utils.playsound("SuperImpact")
		for i in get_tree().get_nodes_in_group("obj_baddie"):
			if (i.is_on_floor() && i.screenvisible):
				i.state = global.states.stun
				i.velocity.y = -7
				i.velocity.x = 0
				i.stunned = 200
		for i in get_tree().get_nodes_in_group("obj_camera"):
			i.shake_mag = 20
			i.shake_mag_acc = (40 / 30)
		$Sprite.frame = 0
		$Sprite.speed_scale = 0.35
		flash = false
		combo = 0
		velocity.x = 2.5 * (-xscale)
		velocity.y = -3
		mach2 = 0
		utils.instance_create(position.x + 10, position.y + 10, "res://Objects/Visuals/Effects/obj_bumpeffect.tscn")
		utils.playsound("Bump")
	if (is_on_floor()):
		$Sprite.animation = "machroll"
	if ($Sprite.frame == 0):
		flash = true
	else:
		flash = false
	if (!utils.instance_exists("obj_cloudeffect") && is_on_floor()):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_cloudeffect.tscn")
	$Sprite.speed_scale = 0.6
	
func scr_player_machslide():
	var move = ((-int(Input.is_action_pressed("key_left"))) + int(Input.is_action_pressed("key_right")))
	mach2 = 0
	velocity.x = (xscale * movespeed)
	if (movespeed >= 0):
		movespeed -= 0.4
	landAnim = false
	if (floor(velocity.x) == 0):
		movespeed = 0
		state = global.states.normal
		movespeed = 4
		mach2 = 0
		machslideAnim = false
	if (floor(velocity.x) == 0 && move != 0 && Input.is_action_pressed("key_dash")):
		machhitAnim = false
		state = global.states.mach2
		xscale *= -1
		mach2 = 35
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_jumpdust.tscn")
	if (is_colliding_with_wall()):
		machhitAnim = false
		machslideAnim = true
		movespeed = 0
		$Sprite.frame = 0
		state = global.states.bump
		velocity.x = 2.5 * (-xscale)
		velocity.y = -3
		mach2 = 0
		utils.instance_create(position.x + 10, position.y + 10, "res://Objects/Visuals/Effects/obj_bumpeffect.tscn")
		utils.playsound("Bump")
	if (machslideAnim):
		$Sprite.animation = "machslidestart"
		if (is_last_frame()):
			machslideAnim = false
	if (!machslideAnim):
		$Sprite.animation = "machslide"
	$Sprite.speed_scale = 0.35
	if (!utils.instance_exists("obj_slidecloud") && is_on_floor() && movespeed > 5):
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_slidecloud.tscn")
	
func scr_player_bump():
	if (is_on_floor() && velocity.y >= 0):
		velocity.x = 0
	if (is_last_frame()):
		state = global.states.normal
	movespeed = 0
	mach2 = 0
	$Sprite.animation = "bump"
	$Sprite.speed_scale = 0.35
	
func scr_player_Sjump():
	mach2 = 0
	jumpAnim = true
	landAnim = false
	machslideAnim = true
	crouchAnim = false
	machhitAnim = false
	movespeed = 0
	velocity.y -= 1
	if (Input.is_action_just_pressed("key_dash")):
		$Sprite.animation = "mach2jump"
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_machsuperjump1.tscn")
		utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_machsuperjump2.tscn")
		state = global.states.freefallprep
		velocity.y = -4
		mach2 = 35
	if (is_on_ceiling()):
		for i in get_tree().get_nodes_in_group("obj_baddie"):
			if (i.is_on_floor() && i.screenvisible):
				i.state = global.states.stun
				i.velocity.y = -7
				i.velocity.x = 0
				i.stunned = 200
		for i in get_tree().get_nodes_in_group("obj_camera"):
			i.shake_mag = 10
			i.shake_mag_acc = (30 / 30)
		combo = 0
		state = global.states.Sjumpland
		machhitAnim = false
		var effectid = utils.instance_create(position.x, position.y, "res://Objects/Visuals/Effects/obj_bangeffect.tscn")
		effectid.scale.x = xscale
		utils.playsound("FreefallLand")
	$Sprite.animation = "superjump"
	$Sprite.speed_scale = 0.5
	
func scr_player_Sjumpland():
	mach2 = 0
	jumpAnim = true
	landAnim = false
	machslideAnim = true
	crouchAnim = false
	machhitAnim = false
	movespeed = 0
	velocity.y = 0
	velocity.x = 0
	$Sprite.animation = "superjumpland"
	if (is_last_frame()):
		state = global.states.jump
		jumpAnim = false

func scr_player_Sjumpprep():
	combo = 0
	movespeed = 4
	mach2 = 0
	jumpAnim = true
	landAnim = false
	machslideAnim = true
	crouchAnim = true
	if (is_last_frame()):
		utils.playsound("Plane")
		state = global.states.Sjump
		velocity.y = -15
	$Sprite.animation = "superjumpprep"
	$Sprite.speed_scale = 0.35

func scr_playersounds():
	if ((state == global.states.normal || (state == global.states.grabbing && is_on_floor())) && velocity.x != 0 && !utils.soundplaying("Footsteps")):
		utils.playsound("Footsteps")
	if (((state != global.states.normal && state != global.states.grabbing) || state == global.states.normal && velocity.x == 0) && utils.soundplaying("Footsteps")):
		utils.stopsound("Footsteps")
	if (state == global.states.mach1 && !utils.soundplaying("Mach1")):
		utils.playsound("Mach1")
	if (state == global.states.mach2):
		if (is_on_floor() && !utils.soundplaying("Mach2")):
			utils.playsound("Mach2")
		elif (!utils.soundplaying("Spin") && !is_on_floor()):
			utils.playsound("Spin")
	if (state == global.states.mach3):
		if (!utils.soundplaying("Mach2")):
			utils.playsound("Mach2")
		if (!utils.soundplaying("Woop")):
			utils.playsound("Woop")
	if (state == global.states.machroll && !utils.soundplaying("Roll")):
		utils.playsound("Roll")
	if (state != global.states.Sjump && utils.soundplaying("Plane")):
		utils.stopsound("Plane")

func _on_WhiteFlashTimer_timeout():
	flash = false
