extends Area2D

export (String) var city = "listite"
export (String) var to_location = "example1"
export (String) var location_name = ""
export (String) var from
var path_terrain
var path_ysort

func _ready():
	get_tree().call_group("mark_system","node_added",self,"location")
	$Label.text = "To "+location_name

func _on_Teleport_area_entered(area):
	var player = area.get_parent()
	player.state = 4
	var game=get_tree().get_root().get_node("Game")
	var file2Check = File.new()
	var doFileExists = file2Check.file_exists("res://assets/scene/Maps/"+city+"/"+to_location+"/NavMap.tscn")
	if doFileExists:
		var loading = game.set_loadingscreen(true)
		get_tree().paused = true
		yield(get_tree().create_timer(1),"timeout")
		get_tree().paused = false
		delete_spawn()
		yield(get_tree().create_timer(0.5),"timeout")
		get_tree().call_group("mapqueue","kill_me")
		path_terrain=load("res://assets/scene/Maps/"+city+"/"+to_location+"/NavMap.tscn")
		var node=Global.instance_node(path_terrain)
		node.player_in = from
		Global.spawn_node_deferred(node,get_tree().get_root().get_node("Game/World/MapManager"))
		loading.loading_finish()
		player.state = 0
	else:
		player.global_position = get_parent().get_node("From_"+to_location).global_position
		get_tree().call_group("Dialog","set_dialog","System","Maps still on working! Please be patient or waiting.","none",true)
		player.state = 0

func delete_spawn():
	get_tree().call_group("enemies","queue_free")
	get_tree().call_group("Item","delete_all_item")
	get_tree().call_group("Boneflesh","delete_all_flesh")
	get_tree().call_group("travel","queue_free")
	
	
	
