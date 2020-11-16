extends Node

enum ui{
	SWITCH,
	MENUGAMESELECT,
	MENUGAMECANCEL,
	MENUSELECT,
	MENUCANCEL,
	SHOPACTION,
	QUESTCOMPLETE,
	OBJCOMPLETE,
	INVENTORYSELECT,
	INVENTORYDESELECT
}
enum effect{
	GETITEM =200,
	LEVELUP=201,
	REGENWATER=202,
	RANGEHURT=203,
	MELEEHURT=204,
	SHOT=205,
	USEITEM=206,
	WATERSHOT=207,
	WATERSPLASH=208,
	CASTINGWATER=209,
	WATERSPLASHLOOP=210,
	
}

var res_bgm = ""
var volume_bgm = 100 setget set_vbgm
var volume_sfx = 100 setget set_vsfx

func set_vbgm(v):
	volume_bgm = v
	var newv = -30+(0.3*v)
	print (newv)
	if v <= 0:
		AudioServer.set_bus_mute(1,true)
	else:
		AudioServer.set_bus_mute(1,false)
		AudioServer.set_bus_volume_db(1,newv)

func set_vsfx(v):
	volume_sfx = v
	var newv = -30+(0.3*v)
	print (newv)
	if v <= 0:
		AudioServer.set_bus_mute(2,true)
	else:
		AudioServer.set_bus_mute(2,false)
		AudioServer.set_bus_volume_db(2,newv)

func set_bgm(path_res):
	var res= load(path_res)
	var n =Global.instance_node(load("res://assets/scene/Music/BGM.tscn"))
	n.res_bgm = res
	Global.spawn_node(n,get_tree().get_root())

func set_sfx(path_res,is_expire=true):
	var res
	if typeof(path_res) == TYPE_STRING:
#		print("STRING PATH")
		res= load(path_res)
	else:
#		print("ENUM PATH")
		res= get_music(path_res)
	var n =Global.instance_node(load("res://assets/scene/Music/SFX.tscn"))
	n.res_sfx = res
	if is_expire:
		n.is_expire = true
	Global.spawn_node(n,get_tree().get_root())
	return n

func set_sfx2d(path_res,target,is_expire=true):
	var res
	if typeof(path_res) == TYPE_STRING:
#		print("STRING PATH")
		res= load(path_res)
	else:
#		print("ENUM PATH")
		res= get_music(path_res)
	var noded =Global.instance_node(load("res://assets/scene/Music/SFX2D.tscn"))
	noded.res_sfx = res
	noded.target = target
	if is_expire:
		noded.is_expire = true
	if is_instance_valid(target):
		Global.spawn_node(noded,target)
	else:
		print("SFX Failed to spawn. Invalid Target")
	return noded

func get_music(enu):
	var res
#	print(enu)
	match enu:
		ui.MENUCANCEL:
			res = load("res://assets/sfx/ui/mainmenu_back.wav")
		ui.MENUSELECT:
			res = load("res://assets/sfx/ui/mainmenu_select.wav")
		ui.MENUGAMECANCEL:
			res = load("res://assets/sfx/ui/menugame_back.wav")
		ui.MENUGAMESELECT:
			res = load("res://assets/sfx/ui/menugame_select.wav")
		ui.OBJCOMPLETE:
			res = load("res://assets/sfx/ui/objectivecomplete.wav")
		ui.QUESTCOMPLETE:
			res = load("res://assets/sfx/ui/questcomplete.wav")
		ui.SHOPACTION:
			res = load("res://assets/sfx/ui/shopaction.wav")
		ui.SWITCH:
			res = load("res://assets/sfx/ui/menu_switch.wav")
		ui.INVENTORYSELECT:
			res = load("res://assets/sfx/ui/inventoryselect.wav")
		ui.INVENTORYDESELECT:
			res = load("res://assets/sfx/ui/inventorydeselect.wav")
	match enu:
		effect.GETITEM:
			res = load("res://assets/sfx/effect/getitem.wav")
		effect.LEVELUP:
			res = load("res://assets/sfx/effect/levelup.wav")
		effect.REGENWATER:
			randomize()
			var arr = ["regenwater1.wav","regenwater2.wav","regenwater3.wav","regenwater4.wav"]
			res = load("res://assets/sfx/effect/"+arr[randi()%4])
		effect.SHOT:
			res = load("res://assets/sfx/effect/shot.wav")
		effect.USEITEM:
			res = load("res://assets/sfx/effect/useitem.wav")
		effect.WATERSHOT:
			res = load("res://assets/sfx/effect/water.wav")
		effect.WATERSPLASH:
			res = load("res://assets/sfx/effect/water_splash1.wav")
		effect.WATERSPLASHLOOP:
			res = load("res://assets/sfx/effect/water_splash_loop.wav")
		effect.CASTINGWATER:
			res = load("res://assets/sfx/effect/casting_water.wav")
		effect.MELEEHURT:
			res = load("res://assets/sfx/effect/Hurt.wav")
		effect.RANGEHURT:
			res = load("res://assets/sfx/effect/Hit.wav")
	return res

func free_bgm():
	get_tree().call_group("bgm","bgm_finish")

func menu_bgm(is_show):
	if is_show:
		get_tree().call_group("bgm","bgm_pause",true)
	else:
		get_tree().call_group("bgm","bgm_pause",false)
