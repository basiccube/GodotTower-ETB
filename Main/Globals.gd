extends Node

var panic = false
var saveroom = []
var baddieroom = []
var targetLevel = ""
var targetRoom = ""
var targetDoor = "A"

var minutes = 0
var seconds = 59

var collect = 0
var shroomfollow = false
var cheesefollow = false
var tomatofollow = false
var sausagefollow = false
var pineapplefollow = false

var key_inv = false
var keyget = false

enum states {
	normal,
	jump,
	crouch,
	crouchjump,
	crouchslide,
	mach1,
	mach2,
	mach3,
	mach4,
	machslide,
	machroll,
	machfreefall,
	freefallprep,
	freefallland,
	freefall,
	facestomp,
	bump,
	door,
	comingoutdoor,
	timesup,
	gameover,
	gottreasure,
	grab,
	hurt,
	highjump,
	keyget,
	knightpep,
	knightpepattack,
	ladder,
	Sjump,
	Sjumpprep,
	Sjumpland,
	victory,
	uppunch,
	backkick,
	backbreaker,
	throw,
	slam,
	superslam,
	shoulder,
	punch,
	idle,
	walk,
	turn,
	stun,
	stomped,
	rolling,
	recovery,
	land,
	grabbed,
	hit,
	hitwall,
	hitceiling,
}
