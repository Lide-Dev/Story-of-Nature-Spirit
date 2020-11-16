extends Control

onready var powdertag = $CenterContainer2/VBoxContainer/CostValue
onready var buttonrevive = $CenterContainer2/VBoxContainer/HBoxContainer/Revive
onready var buttonmainmenu = $CenterContainer2/VBoxContainer/HBoxContainer/MainMenu
var player
var world
var powder = 0
var gui
var game

func _ready():
	game = get_tree().get_root().get_node("Game")
	gui = game.get_node("GUI")
#	gui.stat.connect("no_health",self,"_on_Stats_no_health")
	add_to_group("Revive")

func revive_show():
	show()
	world=gui.world
	player=world.player
	if world.level < 5:
		powder=0
	else:
		powder = world.level*50
	powdertag.text = "Cost: "+str(powder)+" Pollen"

func revive_cancel():
	hide()
	game.quit_game()

func revive_process():
	var loc = world.revive_location
	game=get_tree().get_root().get_node("Game")
	game.death = false
	var file2Check = File.new()
	var doFileExists = file2Check.file_exists("res://assets/scene/Maps/"+loc["city"]+"/"+loc["location"]+"/NavMap.tscn")
	if doFileExists:
		var loading = game.set_loadingscreen(true)
		get_tree().paused = true
		yield(get_tree().create_timer(1),"timeout")
		player.revive()
		world.stats.revive()
		player.state = 4
		get_tree().paused = false
		get_tree().call_group("enemies","queue_free")
		get_tree().call_group("Item","delete_all_item")
		get_tree().call_group("Boneflesh","delete_all_flesh")
		yield(get_tree().create_timer(0.5),"timeout")
		get_tree().call_group("mapqueue","kill_me")
		var path_terrain=load("res://assets/scene/Maps/"+loc["city"]+"/"+loc["location"]+"/NavMap.tscn")
		var node=Global.instance_node(path_terrain)
		node.init = true
		Global.spawn_node_deferred(node,get_tree().get_root().get_node("Game/World/MapManager"))
		loading.loading_finish()
		player.state = 0

func _on_Revive_pressed():
	var pollen = world.stats_game["pollen"]
	if (powder<=pollen):
		pollen-=powder
		revive_process()
		hide()
	else:
		Global.create_alert("Not Enough Pollen")

func _on_MainMenu_pressed():
	revive_cancel()
	pass # Replace with function body.
