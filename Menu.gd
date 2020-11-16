extends CanvasLayer

signal newgame_started

onready var video = $VideoPlayer
onready var loadingscreen 
onready var menu = $Menu
onready var anim = $Menu/AnimationPlayer
onready var new_game = $Menu/Button/VBoxContainer/NewGame
onready var exit = $Menu/Button/VBoxContainer/Exit
onready var conti = $Menu/Button/VBoxContainer/Continue
onready var contivisual = $Menu/Visual/VBoxContainer/Continue
var firstloading
var loading
var game
var available_save = false

func _ready():
	game = get_tree().get_root().get_node("Game")

func init_stats(st):
	st.maxhp = 7
	st.maxpp = 5
	st.defense = 0
	st.attack = 3
	st.speed = 100

func _on_VideoPlayer_finished():
	$VideoPlayer.hide()
	firstloading=game.set_loadingscreen(true)
	yield(get_tree().create_timer(2),"timeout")
	menu.show()
	var sec=firstloading.loading_finish()
	yield(get_tree().create_timer(0.8),"timeout")
	MusicSystem.set_bgm("res://assets/bgm/Home-Forest_Looping.ogg")
	if game.check_savegame():
		conti.disabled = false
		contivisual.modulate = Color.white
		available_save = true
	

func _on_NewGame_mouse_entered():
	anim.play("ButtonNewFocus")
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH,true)

func _on_NewGame_mouse_exited():
	anim.stop()
	anim.play("ButtonNormal")

func _on_Exit_mouse_entered():
	anim.play("ButtonExitFocus")
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH,true)

func _on_Exit_mouse_exited():
	anim.stop()
	anim.play("ButtonNormal")

func _on_Continue_mouse_exited():
	anim.stop()
	anim.play("ButtonNormal")

func _on_Continue_mouse_entered():
	if available_save:
		anim.play("ButtonContinueFocus")
		MusicSystem.set_sfx(MusicSystem.ui.SWITCH,true)

func _on_Continue_pressed():
	game.death = false
	get_tree().call_group("bgm","bgm_finish")
	MusicSystem.set_sfx(MusicSystem.ui.MENUSELECT,true)
	loading=game.set_loadingscreen(true)
	loading.loading_start()
	yield(get_tree().create_timer(0.2),"timeout")
	print("Hide Menu")
	menu.hide()
	yield(get_tree().create_timer(1),"timeout")
	#CREATE GUI=========================
	print("Create GUI")
	var gui_path= load("res://assets/scene/UI/GUI.tscn")
	var gui_node= Global.instance_node(gui_path)
	gui_node.layer = 0
	Global.spawn_node_deferred(gui_node,get_tree().get_root().get_node("Game"))
	yield(get_tree().create_timer(2),"timeout")
	#CREATE Stat Player=========================
	var stats_path = load("res://assets/scene/Stats.tscn")
	var stats_node= Global.instance_node(stats_path)
	stats_node.is_player = true
	init_stats(stats_node)
	Global.spawn_node_deferred(stats_node,get_tree().get_root().get_node("Game"))
	print("Create Stats Player and Create World")
	#CREATE World=========================
	var world_path= load("res://World.tscn")
	var world_node= Global.instance_node(world_path)
	var quest_path = load("res://assets/scene/Quest.tscn")
	var quest_node = Global.instance_node(quest_path)
	world_node.is_newgame = false
	quest_node.is_newgame = false
	world_node.gui = gui_node
	quest_node.world = world_node
	world_node.quest = quest_node
	stats_node.quest = quest_node
	world_node.stats = stats_node
	gui_node.stat = stats_node
	Global.spawn_node_deferred(quest_node,get_tree().get_root().get_node("Game"))
	Global.spawn_node_deferred(world_node,get_tree().get_root().get_node("Game"))
	yield(get_tree().create_timer(2),"timeout")
	print("Done")
	#Loading Finish=========================
	loading.loading_finish()
	emit_signal("newgame_started")
	gui_node.ready_all()
	var data =game.load_game()
	print("Load World...")
	world_node.load_game(data.world)
	print("Load Stats...")
	stats_node.load_game(data.stats)
	print("Load Quest...")
	quest_node.load_game(data.quest)
	yield(get_tree().create_timer(1),"timeout")
	gui_node.layer=1
	game.statusGame = 1

func cinematic_play():
	Global.spawn_node(Global.instance_node("res://assets/scene/Cinematic/Introduction/Cinematic_Introduction.tscn"),get_tree().get_root().get_node("Game"))

func _on_NewGame_pressed():
	get_tree().call_group("bgm","bgm_finish")
	MusicSystem.set_sfx(MusicSystem.ui.MENUSELECT,true)
	loading=game.set_loadingscreen(true)
	loading.loading_start()
	yield(get_tree().create_timer(1),"timeout")
	menu.hide()
	loading.loading_finish()
	yield(get_tree().create_timer(1),"timeout")
	cinematic_play()

func _on_Exit_pressed():
	game.end_game()
	pass # Replace with function body.

func temp_newgame():
	game.death = false
	print("NEWGAME")
	get_tree().call_group("bgm","bgm_finish")
	MusicSystem.set_sfx(MusicSystem.ui.MENUSELECT,true)
	loading=game.set_loadingscreen(true)
	
	loading.loading_start()
	yield(get_tree().create_timer(0.2),"timeout")
	print("Hide Menu")
	menu.hide()
	yield(get_tree().create_timer(1),"timeout")
	#CREATE GUI=========================
	print("Create GUI")
	var gui_path= load("res://assets/scene/UI/GUI.tscn")
	var gui_node= Global.instance_node(gui_path)
	gui_node.layer = 0
	Global.spawn_node_deferred(gui_node,get_tree().get_root().get_node("Game"))
	yield(get_tree().create_timer(2),"timeout")
	#CREATE Stat Player=========================
	var stats_path = load("res://assets/scene/Stats.tscn")
	var stats_node= Global.instance_node(stats_path)
	stats_node.is_player = true
	init_stats(stats_node)
	Global.spawn_node_deferred(stats_node,get_tree().get_root().get_node("Game"))
	print("Create Stats Player and Create World")
	#CREATE World=========================
	var world_path= load("res://World.tscn")
	var world_node= Global.instance_node(world_path)
	var quest_path = load("res://assets/scene/Quest.tscn")
	var quest_node = Global.instance_node(quest_path)
	world_node.is_newgame = true
	quest_node.is_newgame = true
	world_node.gui = gui_node
	quest_node.world = world_node
	world_node.quest = quest_node
	stats_node.quest = quest_node
	world_node.stats = stats_node
	gui_node.stat  = stats_node
	Global.spawn_node_deferred(quest_node,get_tree().get_root().get_node("Game"))
	Global.spawn_node_deferred(world_node,get_tree().get_root().get_node("Game"))
	yield(get_tree().create_timer(2),"timeout")
	print("Done")
	#Loading Finish=========================
	loading.loading_finish()
	emit_signal("newgame_started")
	gui_node.ready_all()
	yield(get_tree().create_timer(1),"timeout")
	gui_node.layer=1


func _on_Button2_pressed():
	$Menu/OptionContainer.show()
	pass # Replace with function body.
