extends Node2D

signal xp_changed(xp)
signal inventorystack_changed

var inventory= {"flowernectar":{"stack":3},"smallpotion":{"stack":5},"concorb":{"stack":1}}
var useitem = "none" setget set_useitem
var xp:int = 0 setget set_xp
var xp_next_level:int = 5
var xp_previous_level:int = 0
var main_point = 1
var skill_point = 1
var level = 1
var stats
var activeskill= {"attack":[],"passive":[]}
var is_newgame=false
var stats_game = {"pollen":200,"fol":10,"rship":{"Listia":0,"Roe":0,"Umiom":0},"alchemy":0}
var quest
var revive_location = {"city": "", "location": ""}
var current_location = {"city": "", "location": ""}
var equipment = {"head":"","orb1":"","orb2":"","ring":""}
var equipBullet = "WaterShot"
var game
var gui
var skilltree= {}

onready var player = $MapManager/PlayerYSort/Player

func _ready():
	game = get_tree().get_root().get_node("Game")
	add_to_group("World")
	$MapManager.add_to_group("MapManager")
	if is_newgame:
		var path = load("res://assets/scene/Maps/listite/treehouse/NavMap.tscn")
		var node=Global.instance_node(path)
		node.init = true
		Global.spawn_node(node,$MapManager)
		set_currentlocation("listite","treehouse")
		init_skilltree()
	stats.connect("no_health",player,"_on_Stats_no_health")

func init_skilltree():
	var keys = DataImport.skill_data.keys()
	for key in keys:
		var value
		if str(DataImport.skill_data[key].value) != "-":
			value = float(DataImport.skill_data[key].value)
		else:
			value = DataImport.skill_data[key].value
		skilltree[key]={
			"lvl":0,
			"value": value,
			"toggled": false
		}
	stats.skilltree = skilltree
#	player.skilltree = skilltree

func set_skilltree(key,att,value):
	skilltree[key][att] = value
	stats.skilltree = skilltree
	stats.update_stat()

func get_skilltree(key="",att=""):
	if skilltree.has(key):
		if key=="":
			return skilltree
		elif att=="":
			return skilltree[key]
		else:
			return skilltree[key][att]
	else:
		return 0

func load_game(value):
	var keys = value.keys()
	var positions =Vector2(0,0)
	for key in keys:
		if key=="pos_x": 
			positions.x = value[key]
		elif key=="pos_y":
			positions.y = value[key]
		else:
			set(key,value[key])
	if !keys.has("skilltree"):
		init_skilltree()
		skill_point=level
	else:
		var a = skilltree.keys()
		for key in a:
			skilltree[key].value = DataImport.skill_data[key].value
	player.skilltree = skilltree
	var path = load("res://assets/scene/Maps/"+current_location.city+"/"+current_location.location+"/NavMap.tscn")
	var node=Global.instance_node(path)
	set_loadequipment()
	player.effect_equipment()
	stats.update_stat()
	node.load_position= positions
	node.init = true
	Global.spawn_node(node,$MapManager)

func set_loadequipment():
	var keys = equipment.keys()
	for key in keys:
		print("EQUIPMENT LOAD")
		print (key)
		var value = equipment[key]
		print (value)
		if (value != ""):
			add_statequipment(key,value)
		else:
			remove_statequipment(key)
		
		if key == "orb1":
			if value != "":
				gui.set_shortcutBullet("Skillbox2",DataImport.equip_data[value].bullet)
			else:
				gui.set_shortcutBullet("Skillbox2","none")
		
		elif key == "orb2":
			if value != "":
				gui.set_shortcutBullet("Skillbox3",DataImport.equip_data[value].bullet)
			else:
				gui.set_shortcutBullet("Skillbox3","none")

func set_equipment(key,value):
	if (equipment[key]=="" and value != ""):
		equipment[key]=value
		print("ADD")
		add_statequipment(key,value)
	else:
		print("REMOVE")
		remove_statequipment(key)
		if value != "":
			print("ADD AGAIN")
			equipment[key]=value
			add_statequipment(key,value)
			
	if key == "orb1":
		if value != "":
			gui.set_shortcutBullet("Skillbox2",DataImport.equip_data[value].bullet)
		else:
			gui.set_shortcutBullet("Skillbox2","none")
	elif key == "orb2":
		if value != "":
			gui.set_shortcutBullet("Skillbox3",DataImport.equip_data[value].bullet)
		else:
			gui.set_shortcutBullet("Skillbox3","none")
	player.effect_equipment()
	stats.update_stat()
	print(equipment)

func add_statequipment(key,value):
	var stat_data = ["maxhp","maxpp","luck","attack","defense","speed","soil","slip","fert"]
	var stat_list = ["maxhp","maxpp","luck","attack","defense","speed","soil","slippery","fertility"]
	var equip = DataImport.equip_data[value]
	var i = 0
	for stat in stat_data:
		if int(equip[stat]) != 0:
			if str(equip[stat]).is_valid_float():
				stats.equipstat[key][stat_list[i]] = float(equip[stat])
#				print("Float add stat equip: "+str(stats.equipstat[key][stat_list[i]]))
			else:
				stats.equipstat[key][stat_list[i]] = int(equip[stat])
#				print("INT add stat equip: "+str(stats.equipstat[key][stat_list[i]]))
		i+=1
#	print(stats.equipstat)

func remove_statequipment(key):
	stats.equipstat[key] = {}
#	print(stats.equipstat)

func set_pollen(pl):
	stats_game.pollen = pl
	quest.update_stat("pollen",pl)

func set_fol(fl):
	stats_game.fol = fl
	quest.update_stat("fol",fl)

func set_revivelocation(city,location):
	revive_location["city"]=city
	revive_location["location"]=location
	
func set_currentlocation(city,location):
	game = get_tree().get_root().get_node("Game")
	current_location["city"]=city
	current_location["location"]=location
	game.get_node("GUI").change_location(city,location)

func set_xp(xxp):
	xp = xxp
	if xp >= xp_next_level:
		MusicSystem.set_sfx(MusicSystem.effect.LEVELUP)
		main_point += 1
		skill_point += 1
		Global.create_txt(player.global_position,"Level Up!")
		level+=1
		xp_previous_level=xp_next_level
#		if level > 10:
		xp_next_level += xp_previous_level+(xp_previous_level*0.5)
#		else:
#			xp_next_level += int(xp_previous_level*0.5)
	emit_signal("xp_changed",xp)
	quest.update_stat("xp",xp)
	
func set_invstack(key,value):
	inventory[key].stack += value
	if inventory[key].stack <= 0:
		inventory.erase(key)
	emit_signal("inventorystack_changed")

func set_useitem(name):
	if str(DataImport.item_data[name].type) != "3":
		var valid = true
		var error = ""
		if DataImport.item_data[name].state != "none":
			var array = DataImport.item_data[name].state.split(",",true,0)
			for arr in array:
				match DataImport.state_data[arr].state_trigger:
					"attack":
						activeskill["attack"].push_back(arr)
					"passive":
						activeskill["passive"].push_back(arr)
					"interact":
						var a=interact_state(arr)
						valid = a[0]
						error = a[1]
		if valid:
			use_item(name)
			if int(DataImport.item_data[name].exp) > 0:
				set_xp(xp + int(DataImport.item_data[name].exp))
				get_tree().call_group("logtext","set_text","It's increase your XP to "+str(xp)+"!")
			set_invstack(name, -1)
			MusicSystem.set_sfx2d(MusicSystem.effect.USEITEM,self)
		else:
			get_tree().call_group("logtext","set_text",error)
	else:
		set_invstack(name, -1)
		MusicSystem.set_sfx2d(MusicSystem.effect.USEITEM,self)
		Global.create_alert("Equip "+DataImport.item_data[name].real_name+"!")

func use_item(item_name):
	var value = DataImport.item_data[item_name].duplicate()
	var keys = ["hp","pp","wp","attack","defense","soil","slip","fert"]
	var statkeys = ["hp","pp","wp","attack","defense","soil","slippery","fertility"]
	var maxkeys = ["maxhp","maxpp","maxhp","attack","defense","soil","slippery","fertility"]
	var stringkeys=["Hit Points","Powder Points","Water Points","Attack","Defense","Soil","Slippery","Fertility"]
	var i = 0
	for key in keys:
		if str(value[key]) != "0":
			var text
			var param =str(value[key]).split(",",true,1)
			var percent
			var temp
			if param[0] == "m":
				text = "decrease"
				if str(param[1]).ends_with("%"):
					percent = param[1].replace("%","")
					temp = stats.get(statkeys[i])-(stats.get(maxkeys[i])* int(percent)*0.01 )
					stats.set(statkeys[i],float(temp))
				else:
					temp = stats.get(statkeys[i])-(float(param[1]))
					stats.set(statkeys[i],temp)
			else:
				text = "increase"
				if str(param[1]).ends_with("%"):
					percent = param[1].replace("%","")
					temp = stats.get(statkeys[i])+(stats.get(maxkeys[i])* float(percent)*0.01 )
					stats.set(statkeys[i],float(temp))
				else:
					temp = stats.get(statkeys[i])+(float(param[1]))
					stats.set(statkeys[i],temp)
			get_tree().call_group("logtext","set_text","It's "+text+" your "+stringkeys[i]+" to "+str(stats.get(statkeys[i]))+"!")
		i+=1
	stats.update_stat()

func add_item(key,stack = 1):
	if inventory.size() <= 0:
		inventory[key] = {"stack":stack}
	else:
		if inventory.has(key):
			set_invstack(key,stack)
		else:
			inventory[key] = {"stack":stack}
#	print(key)
#	print(inventory[key]["stack"])
	quest.update_item(key,inventory[key]["stack"])

func interact_state(value):
	match DataImport.state_data[value].state:
		"water":
			if player.water_interact:
				add_item("watervial")
				return [true,""]
			else:
				return [false,"A watery interaction is required to use this item!"]

func _on_Player_ready():
	var node = get_node("MapManager/PlayerYSort")
	player= node.get_node("Player")
	player.stats = stats
	var status_gui=get_tree().get_nodes_in_group("statusbar_gui")
	status_gui[0].update_bar("hp",stats.hp,stats.maxhp)
	status_gui[0].update_bar("pp",stats.pp,stats.maxpp)
	status_gui[0].update_bar("wp",stats.wp,stats.maxhp)
#	print(player)player.get_node("Stats")
#	player.connect("hp_changed",self,"_on_Player_hp_changed")
#	player.connect("mhp_changed",self,"_on_Player_hp_changed")
	yield(get_tree().create_timer(1),"timeout")
	pass # Replace with function body.

func _on_Player_interact_item(key):
	add_item(key)
	print(inventory)
	pass # Replace with function body.
