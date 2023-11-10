extends Node

onready var GameNode = get_node(@"/root/Game")

func randi_range(from, to):
	if from > to:
		var old_from = from
		from = to
		to = old_from
	return int(floor(rand_range(from , to + 1)))
	
func instance_create(x, y, scene):
	var loadedscene = load(scene)
	var id = loadedscene.instance()
	GameNode.add_child(id)
	id.position = Vector2(x, y)
	return id
	
func instance_create_scene(x, y, scene):
	var id = scene.instance()
	GameNode.add_child(id)
	id.position = Vector2(x, y)
	return id
	
func instance_create_level_scene(x, y, scene):
	var id = scene.instance()
	get_level().add_child(id)
	id.position = Vector2(x, y)
	return id
	
func instance_create_level(x, y, scene):
	var loadedscene = load(scene)
	var id = loadedscene.instance()
	get_level().add_child(id)
	id.position = Vector2(x, y)
	return id
	
func instance_exists(node):
	var instancenode = GameNode.get_node_or_null(node)
	if instancenode == null:
		return false
	else:
		return true
		
func instance_exists_level(node):
	if (get_level() != null):
		var instancenode = get_level().get_node_or_null(node)
		if instancenode == null:
			return false
		else:
			return true
	else:
		return false
		
func get_instance(node):
	var instancenode = GameNode.get_node_or_null(node)
	return instancenode
	
func get_instance_level(node):
	var instancenode = get_level().get_node_or_null(node)
	return instancenode
	
# https://ask.godotengine.org/132513/how-to-get-all-nodes-in-the-tree
func get_all_nodes(var node = get_tree().root, var nodelist = []):
	nodelist.append(node)
	for childnode in node.get_children():
		get_all_nodes(childnode, nodelist)
	return nodelist
	
func get_gamenode():
	return GameNode
	
func playsound(soundname):
	if GameNode.get_node_or_null(soundname) != null:
		GameNode.get_node(soundname).play()
	else:
		print("playsound: Sound " + soundname + " does not exist!")
		
func stopsound(soundname):
	if GameNode.get_node_or_null(soundname) != null:
		GameNode.get_node(soundname).stop()
	else:
		print("stopsound: Sound " + soundname + " does not exist!")
		
func soundplaying(soundname):
	if GameNode.get_node_or_null(soundname) != null:
		if GameNode.get_node_or_null(soundname).playing:
			return true
		else:
			return false
	else:
		return false
	
func get_player():
	var PlayerNode = GameNode.get_node(@"obj_player")
	return PlayerNode
	
func get_level():
	var LevelNode = GameNode.get_node(@"level")
	return LevelNode
	
func room_goto(levelname, roomname):
	var oldlevel = get_level()
	var newroom = "res://Rooms/" + levelname + "/" + roomname + ".tscn"
	var newroomnode = load(newroom)
	var newroominstance = newroomnode.instance()
	global.targetRoom = roomname
	global.targetLevel = levelname
	oldlevel.queue_free()
	yield(get_tree().create_timer(0.01), "timeout")
	newroominstance.name = "level"
	GameNode.add_child(newroominstance)
	for i in get_all_nodes():
		if (i.has_method("room_start")):
			i.call("room_start")
	if (roomname != "rank_room" && roomname != "timesuproom" && roomname != "disclaimer_room"):
		if (global.shroomfollow):
			instance_create_level(utils.get_player().position.x, utils.get_player().position.y, "res://Objects/Collectibles/obj_pizzakinshroom.tscn")
		if (global.cheesefollow):
			instance_create_level(utils.get_player().position.x, utils.get_player().position.y, "res://Objects/Collectibles/obj_pizzakincheese.tscn")
		if (global.tomatofollow):
			instance_create_level(utils.get_player().position.x, utils.get_player().position.y, "res://Objects/Collectibles/obj_pizzakintomato.tscn")
		if (global.sausagefollow):
			instance_create_level(utils.get_player().position.x, utils.get_player().position.y, "res://Objects/Collectibles/obj_pizzakinsausage.tscn")
		if (global.pineapplefollow):
			instance_create_level(utils.get_player().position.x, utils.get_player().position.y, "res://Objects/Collectibles/obj_pizzakinpineapple.tscn")
	
func delete_tile_at(position):
	var level_tilemap = utils.get_instance_level("TileMap")
	if level_tilemap != null:
		var local_position = level_tilemap.to_local(position)
		var tile_position = level_tilemap.world_to_map(local_position)
		level_tilemap.set_cell(tile_position.x, tile_position.y, -1)
