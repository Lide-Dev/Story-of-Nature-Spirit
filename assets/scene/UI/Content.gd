extends Control

export (int) var max_slot=34

onready var inventory_container = $ScrollContainer/InventoryBox
onready var info_item = $ItemInfo/Control/ContentInfo
onready var welcome = $ItemInfo/Control/Welcome/Welcome
onready var text_name = $ItemInfo/Control/ContentInfo/ItemName
onready var text_type = $ItemInfo/Control/ContentInfo/ItemType
onready var text_desc = $ItemInfo/Control/ContentInfo/ItemDesc
onready var text_attr = $ItemInfo/Control/ContentInfo/ItemAttr
onready var button_use = $ItemMonitor/HBoxContainer2/Use
onready var button_delete = $ItemMonitor/HBoxContainer2/Delete
onready var button_shortcut = $ItemMonitor/HBoxContainer/Shortcut

var popup
var list_inventory = []
var worldnode
var inventory_gui={}
var item_slot = preload("res://assets/scene/UI/Item-0.tscn")
var togglenode
var presseditem = "none"
var gui

func _ready():
	popup = get_node("../Popup")
	worldnode=get_tree().get_root().get_node("Game/World")
	gui = get_tree().get_root().get_node("Game/GUI")
	inventory_gui= worldnode.inventory
	var i=0
	while i < max_slot:
		var node = Global.instance_node(item_slot)
		Global.spawn_node(node,inventory_container)
		node.connect("item_toggled",self,"on_item_toggled")
		list_inventory.push_back(node)
		i += 1
	update_inventory()
	
func update_inventory():
	var i = 0
	var much =inventory_gui.size()
	if much >= 0:
		var key = inventory_gui.keys()
		while i < much:
			list_inventory[i].name_item = key[i]
			list_inventory[i].stack = inventory_gui[key[i]].stack
			i += 1

func on_item_toggled(node):
	if is_instance_valid(togglenode):
		if node == togglenode:
			togglenode.set_pressed(false)
			text_attr.text = "Attribute: "
			togglenode = null
			conf_button()
			info_item.hide()
			welcome.show()
		else:
			togglenode.set_pressed(false)
			togglenode = node
			presseditem = togglenode.name_item
			set_infoitem()
			conf_button()
			desc_type()
			info_item.show()
			welcome.hide()
	else:
		togglenode = node
		presseditem = togglenode.name_item
		set_infoitem()
		conf_button()
		desc_type()
		info_item.show()
		welcome.hide()

func set_infoitem():
	text_name.text = DataImport.item_data[presseditem].real_name
	var type
	match str(DataImport.item_data[presseditem].type):
		"0":
			type = "Collectibles"
		"1":
			type = "Consumsables"
		"2":
			type = "Quest Item"
		"3":
			type = "Equipment"
	text_type.text = type
	text_desc.text = DataImport.item_data[presseditem].description

func desc_type():
	if str(DataImport.item_data[presseditem].type)=="1":
		var value = DataImport.item_data[presseditem].duplicate()
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
					value[key] = "+"+str(value[key])+" "
			else:
				value[key] = ""
			text_attr.text += value[key]
			i+=1
	elif str(DataImport.item_data[presseditem].type)=="3":
		print("EQUIPMENT")
		var value = DataImport.equip_data[presseditem].duplicate()
		var stat_data = ["maxhp","maxpp","luck","attack","defense","speed","soil","slip","fert","bullet"]
		var stat_name = ["MaxHP","MaxPP","Luck","Attack","Defense","Speed","Soil","Slippery","Fertility", "Bullet"]
		var i = 0
		for stat in stat_data:
			print(value[stat])
			if str(value[stat]) != "0":
				if str(value[stat]).is_valid_integer():
					if int(value[stat]) < 0:
						value[stat] = str(value[stat])+" "+stat_name[i]+" "
					else:
						value[stat] = "+"+str(value[stat])+" "+stat_name[i]+" "
				elif stat == "bullet":
					if value[stat] !="none":
						value[stat] = "Get "+DataImport.bullet_data[value[stat]].call_name + " Bullet"
					else:
						value[stat] = ""
				else:
					if float(value[stat]) < 0:
						value[stat] = str(value[stat] * 100)+"% "+stat_name[i]+" "
					else:
						value[stat] = "+"+str(value[stat] * 100)+"% "+stat_name[i]+" "
					
			else:
				value[stat] = ""
			text_attr.text += value[stat]
			i+=1
	else:
		text_attr.text = ""

func conf_button():
	if is_instance_valid(togglenode):
		if str(DataImport.item_data[presseditem].type) == "1":
			button_use.text = "Use Item"
			button_use.disabled = false
			button_shortcut.disabled = false
		elif str(DataImport.item_data[presseditem].type) == "3":
			button_use.text = "Equip Item"
			button_use.disabled = false
			button_shortcut.disabled = true
		button_delete.disabled = false
	else:
		button_use.text = "Use Item"
		button_use.disabled = true
		button_shortcut.disabled = true
		button_delete.disabled = true


func _on_Use_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if str(DataImport.item_data[presseditem].type) == "3":
		var a=DataImport.equip_data[presseditem].type
		print("TYPE"+a)
		if a == "orb":
			popup.show()
			popup.get_node("Equip").show()
			popup.nameitem = presseditem
		else:
			print(worldnode.equipment[a])
			if worldnode.equipment[a] == "":
				print(DataImport.equip_data[presseditem].type)
				print(presseditem)
				worldnode.set_equipment(DataImport.equip_data[presseditem].type,presseditem)
			else:
				worldnode.add_item(worldnode.equipment[a],1)
				worldnode.set_equipment(DataImport.equip_data[presseditem].type,presseditem)
			worldnode.set_useitem(presseditem)
	else:
		worldnode.set_useitem(presseditem)
	get_tree().call_group("logtext","set_text","Use  "+DataImport.item_data[presseditem].real_name+" item!")
	check_emptyitem()
	update_inventory()
			
func check_emptyitem():
	var list=list_inventory.find(togglenode)
	if !worldnode.inventory.has(presseditem):
	#		inventory_gui.erase(presseditem)
	#		worldnode.inventory.erase(presseditem)
		
		list_inventory.remove(list)
		
		togglenode.queue_free()
		var node = Global.instance_node(item_slot)
		Global.spawn_node(node,inventory_container)
		node.connect("item_toggled",self,"on_item_toggled")
		list_inventory.push_back(node)
		togglenode = null
		presseditem = "none"
		conf_button()
		info_item.hide()
		welcome.show()
	else:
		togglenode.set_stack(inventory_gui[presseditem].stack)
func _on_Delete_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	popup.show()
	popup.get_node("Delete").show()
	popup.set_deleteitem(presseditem,inventory_gui[presseditem].stack)

func _on_Shortcut_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	popup.show()
	popup.get_node("Shortcut").show()
	popup.set_shortcut(presseditem)

func _on_Popup_delete_accepted(stk):
	worldnode.set_invstack(presseditem,-1*stk)
	togglenode.set_stack(inventory_gui[presseditem].stack)
	var list=list_inventory.find(togglenode)
	if int(worldnode.inventory[presseditem].stack) < 1:
		inventory_gui.erase(presseditem)
		worldnode.inventory.erase(presseditem)
		list_inventory.remove(list)
		togglenode.queue_free()
		var node = Global.instance_node(item_slot)
		Global.spawn_node(node,inventory_container)
		node.connect("item_toggled",self,"on_item_toggled")
		list_inventory.push_back(node)
		togglenode = null
		presseditem = "none"
		conf_button()
		info_item.hide()
		welcome.show()
	update_inventory()

func _on_Use_mouse_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)

func _on_Delete_mouse_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)

func _on_Shortcut_mouse_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)

func _on_Nav_mouse_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)
