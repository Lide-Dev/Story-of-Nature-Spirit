extends CanvasLayer

onready var pathSkill = "res://assets/img/skill/"
onready var shortcutPath = "Skillbar/HBoxContainer/"
onready var revive = $Revive
var startgame = false
var gameplay
onready var menu_content = $MenuGame/SplitMenu
var game
var inventory
var equipSkill = "WaterShot"
var activeSkill = "Skillbox1"
var world
var loadedSkills = {"Skillbox1" : "WaterShot", "Skillbox2" : "none","Skillbox3" : "none"}
var loadedItem = {"Itembox1":"none","Itembox2":"none","Itembox3":"none","Itembox4":"none"} setget set_loadedItem
var nodemenu
var stat

func _ready():
	print(str(get_node("../Menu"))+"TEST")

func _unhandled_input(event):
	if startgame:
		if event.is_action_pressed("ui_skill1"):
			SelectShortcut("Skillbox1")
		if event.is_action_pressed("ui_skill2"):
			SelectShortcut("Skillbox2")
		if event.is_action_pressed("ui_skill3"):
			SelectShortcut("Skillbox3")
		if event.is_action_pressed("ui_skill4"):
			SelectShortcut("Itembox1")
		if event.is_action_pressed("ui_skill5"):
			SelectShortcut("Itembox2")
		if event.is_action_pressed("ui_skill6"):
			SelectShortcut("Itembox3")
		if event.is_action_pressed("ui_skill7"):
			SelectShortcut("Itembox4")

func ready_all():
	game = get_tree().get_root().get_node("Game")
	world = game.get_node("World")
	gameplay=world
	stat.connect("no_health",self,"_on_Stats_no_health")
	startgame=true
	world.connect("inventorystack_changed",self,"on_Inventory_changed")
	inventory=world.inventory
	loadShorcuts()
	loadItemIcon()
	for shortcut in get_tree().get_nodes_in_group("Shorcuts"):
		shortcut.connect("pressed",self,"SelectShortcut", [shortcut.get_parent().get_name()])
		shortcut.connect("mouse_entered",self,"skillFocus", [shortcut.get_parent().get_name()])
		shortcut.connect("mouse_exited",self,"focusExited",[shortcut.get_parent().get_name()])

func set_loadedItem(value):
	loadedItem = value
	loadItemIcon()

func set_shortcutBullet(key,value):
	loadedSkills[key]=value
	loadShorcuts()

func change_location(city,location):
	$Minimap.change_map(city,location)

func loadItemIcon():
	for shortcut in loadedItem.keys():
		var item = loadedItem[shortcut]
		if (item != "none" and inventory.has(item)):
			if inventory[item].stack <= 0:
				world.inventory.erase(item)
				loadedItem[shortcut] = "none"
				get_node(shortcutPath + shortcut + "/IconItem").frame=11
				get_node(shortcutPath + shortcut + "/Stack").text="0"
			else:
				get_node(shortcutPath + shortcut + "/IconItem").frame=int(DataImport.item_data[item].icon)
				get_node(shortcutPath + shortcut + "/Stack").text=str(inventory[item].stack)
		else:
			loadedItem[shortcut] = "none"
			get_node(shortcutPath + shortcut + "/IconItem").frame=11
			get_node(shortcutPath + shortcut + "/Stack").text="0"

func loadShorcuts():
	#print(shortcutPath + "Skillbox1" + "/TextureButton")
	for shortcut in loadedSkills.keys():
		if loadedSkills[shortcut] != "none":
			var skill_icon = load(pathSkill+loadedSkills[shortcut] + "_Icon.png")
			get_node(shortcutPath + shortcut + "/TextureButton").set_normal_texture(skill_icon)
		else:
			get_node(shortcutPath + shortcut + "/TextureButton").set_normal_texture(null)
			SelectShortcut("Skillbox1")
			equipSkill = "WaterShot"

func SelectShortcut(shortcut):
	if ((!activeSkill == shortcut)and("Skillbox" in shortcut)):
		if loadedSkills[shortcut] != "none":
			match shortcut:
				"Skillbox1":
					equipSkill = loadedSkills[shortcut]
					gameplay.equipBullet = equipSkill
					get_node(shortcutPath + shortcut + "/ColorRect").color = Color( "a4fa3804" )
					get_node(shortcutPath + activeSkill + "/ColorRect").color = Color( "00ffffff" )
					Global.create_alert("Equip "+equipSkill+" bullet!")
					activeSkill = shortcut
				"Skillbox2":
					equipSkill = loadedSkills[shortcut]
					gameplay.equipBullet = equipSkill
					get_node(shortcutPath + shortcut + "/ColorRect").color = Color( "a4fa3804" )
					get_node(shortcutPath + activeSkill + "/ColorRect").color = Color( "00ffffff" )
					Global.create_alert("Equip "+equipSkill+" bullet!")
					activeSkill = shortcut
				"Skillbox3":
					equipSkill = loadedSkills[shortcut]
					gameplay.equipBullet = equipSkill
					get_node(shortcutPath + shortcut + "/ColorRect").color = Color( "a4fa3804" )
					get_node(shortcutPath + activeSkill + "/ColorRect").color = Color( "00ffffff" )
					Global.create_alert("Equip "+equipSkill+" bullet!")
					activeSkill = shortcut
	else:
		if ("Itembox" in shortcut):
			if loadedItem[shortcut] != "none":
				match shortcut:
					"Itembox1":
						use_shortcutitem(shortcut)
					"Itembox2":
						use_shortcutitem(shortcut)
					"Itembox3":
						use_shortcutitem(shortcut)
					"Itembox4":
						use_shortcutitem(shortcut)

func use_shortcutitem(shortcut):
	Global.create_alert("Use "+DataImport.item_data[loadedItem[shortcut]].real_name+" item!")
	world.set_useitem(loadedItem[shortcut])
	loadItemIcon()

func menu_open():
	var instance = load("res://assets/scene/UI/StatusContainer.tscn")
	var new_node=Global.instance_node(instance)
	Global.spawn_node_deferred(new_node,menu_content)
	$MenuGame.statenode = new_node
	nodemenu =new_node
	$MenuGame.reset()

func menu_end():
	$MenuGame.container_active = $MenuGame.STATUS
	get_tree().call_group("tooltip","delete")
	nodemenu.queue_free()
	$MenuGame.reset()

func _on_MenuGame_container_changed(container):
	print(container)
	nodemenu = container

func on_Inventory_changed():
	loadItemIcon()

func skillFocus(shortcut):
	print("ok")
	if "Skillbox" in shortcut:
		if loadedSkills[shortcut]!="none":
			var watercost=(DataImport.bullet_data[loadedSkills[shortcut]].cost_wp/stat.maxhp) *100
			Global.create_tooltip(DataImport.bullet_data[loadedSkills[shortcut]].call_name+"\nCost "+str(stepify(watercost,1))+"%","top")
	else:
		if loadedItem[shortcut]!="none":
			var text = ""
			var value = DataImport.item_data[loadedItem[shortcut]].duplicate()
			var keys = ["hp","pp","wp","attack","defense","soil","slip","fert","exp"]
			var stringkeys = ["HP","PP","WP","Attack","Defense","Soil","Slippery","Fertility","XP"]
			var i = 0
			for key in keys:
				if str(value[key]) != "0":
					if keys[i]!="exp":
						var hp =str(value[key]).split(",",true,1)
						if hp[0] == "m":
							value[key] = "-"+hp[1]+" "+stringkeys[i]+" "
						else:
							value[key] = "+"+hp[1]+" "+stringkeys[i]+" "
					else:
						value[key] = "+"+str(value[key])+" "+stringkeys[i]+" "
				else:
					value[key] = ""
				text += value[key]
				Global.create_tooltip(DataImport.item_data[loadedItem[shortcut]].real_name+"\nGet: "+text,"top")
				i+=1
		
	pass

func focusExited(_shortcut):
	print("no")
	Global.delete_tooltip()
	pass

func _on_Stats_no_health():
	yield(get_tree().create_timer(1),"timeout")
	revive.revive_show()
