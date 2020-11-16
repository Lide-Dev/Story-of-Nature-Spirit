extends YSort

onready var dialog = $CanvasLayer/Dialog
var scene = 0
var dialog_active = false
var img_path = "res://assets/img/character/npc/listia.png"
var system_txt = [
	["5 Years from dissapear of Fronne.","Now the city that Radish has acquired is almost all regions except Listite.","Listia has been guarding Listite with all her might until now.","For the past 5 years, you have grown up."]
]
var listia_txt = [
	["Good morning, Raka!","Be careful if you want to get out.","The guard of the city was tightened because the Radish Forces had already occupied Gripoli.","Maybe this is a bit beyond what I said earlier.", "Can I ask you a favor?","I can't leave here because I have to look after this rare plant.","So I want you to bring me water for this plant.","Are you willing? ... ","Thank you, Raka. The closest river here is the river near Listite westward.","Because you are made of earth so you can take the water with your body by bringing your body closer to the river.","Good Luck, Raka!"]
]

func _ready():
	MusicSystem.set_bgm("res://assets/bgm/Once-Around-the-Kingdom_Looping.ogg")
	dialog.set_dialog("System",system_txt[0],"none",true)
	dialog_active = true

func _process(delta):
	if scene == 1:
		scene=2
		$AnimationPlayer.play("scene_fadein")
		yield(get_tree().create_timer(1),"timeout")
		dialog.set_dialog("Listia",listia_txt[0],img_path,true)
		dialog_active=true
	elif scene == 3:
		dialog.remove_from_group("Dialog")
		start_game()
		scene+=1
	if dialog_active:
		if !dialog.dialog_show:
			dialog_active =false
			scene +=1
			print(scene)

func increase_scene():
	scene += 1

func init_stats(st):
	st.maxhp = 7
	st.maxpp = 5
	st.defense = 0
	st.attack = 3
	st.speed = 100

func start_game():
	MusicSystem.free_bgm()
	var game=get_tree().get_root().get_node("Game")
	var menu=game.get_node("Menu/Menu")
	game.death = false
	print("NEWGAME")
	get_tree().call_group("bgm","bgm_finish")
	MusicSystem.set_sfx(MusicSystem.ui.MENUSELECT,true)
	var loading=game.set_loadingscreen(true)
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
#	emit_signal("newgame_started")
	gui_node.ready_all()
	yield(get_tree().create_timer(1),"timeout")
	gui_node.layer=1
	game.statusGame = 1
	queue_free()
