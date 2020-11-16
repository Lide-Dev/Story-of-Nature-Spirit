extends Node2D

enum {
	MENU,
	STARTGAME,
	PAUSEDGAME,
	EXITGAME
}

var menugame 
var animGUI 

var interact_npc = false
var statusGame = MENU
var death = false
var intro = true

func _ready():
	add_to_group("Game")
	pass

func set_interactnpc(value):
	interact_npc = value

func _input(event):
	if (!death and !interact_npc and statusGame==STARTGAME):
		if event.is_action_pressed("ui_menugame"):
			if !is_instance_valid(menugame):
				menugame=$GUI/MenuGame
				animGUI=$GUI/AnimationPlayer
			if menugame.visible:
				MusicSystem.menu_bgm(false)
				MusicSystem.set_sfx(MusicSystem.ui.MENUCANCEL)
				animGUI.play("hidemenu")
				get_tree().paused = false
			else:
				MusicSystem.set_sfx(MusicSystem.ui.MENUSELECT)
				MusicSystem.menu_bgm(true)
				animGUI.play("showmenu")
				get_tree().paused = true
				Global.delete_tooltip()

func check_savegame():
	var save = File.new()
	return save.file_exists("user://savegame.dat")

func save_game():
	var save = File.new()
	
	save.open("user://savegame.dat", File.WRITE)
	
	var world = get_node("World")
	var quest = get_node("Quest")
	var player = world.player
	var stats = world.stats
	var save_data ={
		#===== WORLD DATA ==========
		"world":
		{
			"inventory" : world.inventory,
			"xp_next_level" : world.xp_next_level,
			"xp_previous_level" : world.xp_previous_level,
			"level": world.level,
			"stats_game": world.stats_game,
			"revive_location": world.revive_location,
			"current_location": world.current_location,
			"equipment": world.equipment,
			"equipBullet": world.equipBullet,
			"activeskill": world.activeskill,
			"main_point" : world.main_point,
			"pos_x": player.global_position.x,
			"pos_y": player.global_position.y,
			"skilltree": world.skilltree,
			"skill_point": world.skill_point,
		},
		#===== STATS DATA ==========
		"stats": {
			"soil": stats.soil,
			"slippery": stats.slippery,
			"fertility": stats.fertility,
			"hp": stats.hp,
			"pp": stats.pp,
			"wp": stats.wp
		},
		#===== QUEST DATA ==========
		"quest": {
			"main_quest": quest.main_quest,
			"opti_quest": quest.opti_quest,
			"maincomplete_quest": quest.maincomplete_quest,
			"opticomplete_quest": quest.opticomplete_quest,
			"obj_quest": quest.obj_quest,
			"completemain_count": quest.completemain_count
		}
	}
	save.store_string(to_json(save_data))
	save.close()
	Global.create_alert("Game has been saved!")
	print("Save Game Complete")

func load_game():
	var load_game = File.new()
	load_game.open("user://savegame.dat", File.READ)
	var data = parse_json(load_game.get_as_text())
	load_game.close()
	if typeof(data) == TYPE_DICTIONARY:
		return data
	else:
		printerr("Corrupted data!")

func set_loadingscreen(getnode = false):
	var instance = load("res://assets/scene/UI/LoadingScreen.tscn")
	var node = Global.instance_node(instance)
	Global.spawn_node(node,$Loading)
	node.loading_start()
	if getnode:
		return node

func quit_game():
	statusGame = MENU
	var gui = get_node("GUI")
	var world = get_node("World")
	var stats = world.stats
	var quest = get_node("Quest")
	var loading = set_loadingscreen(true)
	yield(get_tree().create_timer(0.5),"timeout")
	get_tree().paused=true
	yield(get_tree().create_timer(1),"timeout")
	world.queue_free()
	gui.queue_free()
	stats.queue_free()
	quest.queue_free()
	$Menu/Menu.show()
	yield(get_tree().create_timer(0.5),"timeout")
	MusicSystem.free_bgm()
	MusicSystem.set_bgm("res://assets/bgm/Home-Forest_Looping.ogg")
	get_tree().paused=false
	loading.loading_finish()
	if check_savegame():
		var contivisual = get_tree().get_root().get_node("Game/Menu/Menu/Visual/VBoxContainer/Continue")
		var conti = get_tree().get_root().get_node("Game/Menu/Menu/Button/VBoxContainer/Continue")
		conti.disabled = false
		contivisual.modulate = Color.white
		get_tree().get_root().get_node("Game/Menu").available_save = true
	else:
		var contivisual = get_tree().get_root().get_node("Game/Menu/Menu/Visual/VBoxContainer/Continue")
		var conti = get_tree().get_root().get_node("Game/Menu/Menu/Button/VBoxContainer/Continue")
		conti.disabled = true
		contivisual.modulate = Color("565555")
		get_tree().get_root().get_node("Game/Menu").available_save = false
	
func end_game():
	statusGame = EXITGAME
	get_tree().quit()
	
#func _on_LoadingScreen_opening_complete():
#	if intro:
#		get_tree().paused = false
#		intro = false
#		interact_npc = true
#		get_tree().call_group("Dialog","set_dialog",name_npc,text,path,true)
#		print("DIALOG")
#	print("Loading Complete")

func _on_Menu_newgame_started():
	menugame=$GUI/MenuGame
	animGUI=$GUI/AnimationPlayer
	statusGame=STARTGAME
	pass # Replace with function body.

