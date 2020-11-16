extends YSort

var init = false
var player_in = 0
var load_position
onready var nav_map = $NavMap
export (Array) var from 
export (Array) var enemy_spawn
export (NodePath) var checkpoint
export (bool) var peaceful = false
export (String) var city
export (String) var location
var world
var res_travel = preload("res://assets/scene/Maps/Travel.tscn")
var quest

func _ready():
	add_to_group("mapqueue")
	var player = get_tree().get_root().get_node("Game/World/MapManager/PlayerYSort/Player")
	world = get_tree().get_root().get_node("Game/World")
	world.set_currentlocation(city,location)
	MusicSystem.free_bgm()
	MusicSystem.set_bgm("res://assets/bgm/"+DataImport.city_data[location].bgm+".ogg")
	if peaceful:
		world.set_revivelocation(city,location)
	if init:
		if peaceful:
			player.global_position = get_node(checkpoint).global_position
		else:
			if typeof(load_position) == TYPE_VECTOR2:
				player.global_position = load_position
			else:
				printerr("Error cause of no load position!")
				player.global_position = get_node(checkpoint).global_position
	else:
#		print("TEST:"+player_in+" On array :"+str(from.find(player_in)))
#		print(from[from.find(player_in)])
		player.global_position = get_node("From_"+from[from.find(player_in)]).global_position
	get_tree().call_group("camera","set_topleft",$LimitCamera/TopLeft.position)
	get_tree().call_group("camera","set_bottomright",$LimitCamera/BottomRight.position)
	for spawner in enemy_spawn:
		var spawn = get_node(spawner)
		spawn.path_nav = nav_map.get_path()
	spawn_travel()
	
func spawn_travel():
	var n=get_tree().get_nodes_in_group("QuestSystem")
	quest = n[0]
	var obj = quest.obj_quest
	for arr in obj:
		if (arr["type"] == "travel" and arr["unlock"] and !arr["complete"]):
			if location == arr["location"]:
				var node = Global.instance_node(res_travel)
				node.arr_obj = arr
				node.questsystem = quest
				Global.spawn_node(node,self)
				node.add_to_group("travel")

func kill_me():
	queue_free()
