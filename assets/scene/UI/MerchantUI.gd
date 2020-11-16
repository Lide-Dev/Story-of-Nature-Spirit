extends Control

onready var openingcontainer = $First
onready var secondcontainer = $Second
onready var opbuybutton = $First/VBoxContainer/Buy
onready var opsellbutton = $First/VBoxContainer/Sell
onready var opbackbutton = $First/VBoxContainer/Back
onready var itemcontainer = $Second/Content/ScrollContainer/ItemBox
onready var welcomecontainer = $Second/Content/ItemInfo/Control/Welcome
onready var labelwelcome = $Second/Content/ItemInfo/Control/Welcome/Label
onready var desccontainer = $Second/Content/ItemInfo/Control/Description
onready var optionbutton = $Second/Content/ItemMonitor/HBoxContainer2/Option
onready var backbutton = $Second/Content/ItemMonitor/HBoxContainer2/Back
onready var itemname = $Second/Content/ItemInfo/Control/Description/ItemName
onready var itemdesc = $Second/Content/ItemInfo/Control/Description/ItemDesc
onready var itemtype = $Second/Content/ItemInfo/Control/Description/ItemType
onready var itemattr = $Second/Content/ItemInfo/Control/Description/ItemAttr
onready var itempollen = $Second/Content/ItemInfo/Control/Description/ItemPollen
onready var itemfol = $Second/Content/ItemInfo/Control/Description/ItemFoL
onready var popupcontainer = $Second/Popup
onready var popup_tag = $Second/Popup/Control/Tag
onready var popup_itemname = $Second/Popup/Control/NameandStack
onready var popup_itemcount = $Second/Popup/Control/HBoxContainer/LineEdit
onready var popup_pollen = $Second/Popup/Control/HBoxContainer3/PricePollen
onready var popup_fol = $Second/Popup/Control/HBoxContainer3/PriceFoL
onready var popup_up = $Second/Popup/Control/HBoxContainer/Up
onready var popup_down = $Second/Popup/Control/HBoxContainer/Down
onready var popup_accept = $Second/Popup/Control/HBoxContainer2/Accept
onready var popup_back = $Second/Popup/Control/HBoxContainer2/Cancel
onready var pollenplayer = $Second/Content/ItemMonitor/HBoxContainer2/Pollen/PollenValue
onready var folplayer = $Second/Content/ItemMonitor/HBoxContainer2/FoL/FoLValue

var npc_event
var item_slot = preload("res://assets/scene/UI/Item-0.tscn")
var max_slot = 20
var list_item = []
var item_buy = {}
var item_sell = {}
var type_market = ""
var player
var world
var togglenode
var presseditem
var stackgui=1
var stack
var pricepol
var pricefol
var fol
var pollen
var countbuy=0
var countsell=0
var gui
var game

func _ready():
	get_tree().paused=true
	world=get_tree().get_root().get_node("Game/World")
	gui=get_tree().get_root().get_node("Game/GUI")
	gui.get_node("Minimap").hide()
	var arr=get_tree().get_nodes_in_group("player")
	player = arr[0]
	item_sell = world.inventory
	pollen=world.stats_game["pollen"]
	fol=world.stats_game["fol"]
	pollenplayer.text = str(pollen)
	folplayer.text = str(fol)
	get_tree().call_group("Game","set_interactnpc",true)
	

func update_inventory(item):
	var i = 0
	var much =item.size()
	if much >= 0:
		var key = item.keys()
		while i < much:
			list_item[i].name_item = key[i]
			list_item[i].stack = item[key[i]].stack
			i += 1

func conf_button():
	if is_instance_valid(togglenode):
		optionbutton.disabled = false
	else:
		optionbutton.disabled = true

func set_price():
	pollenplayer.text = str(pollen)
	folplayer.text = str(fol)

func set_infoitem():
	itemname.text = DataImport.item_data[presseditem].real_name
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
	itemtype.text = type
	itemdesc.text = DataImport.item_data[presseditem].description
	if DataImport.item_data[presseditem][type_market+"pl"] > 0:
		itempollen.show()
		itempollen.text="Pollen: "+str(DataImport.item_data[presseditem][type_market+"pl"])
	else:
		itempollen.hide()
	if DataImport.item_data[presseditem][type_market+"fol"] > 0:
		itemfol.show()
		itemfol.text="FoL: "+str(DataImport.item_data[presseditem][type_market+"fol"])
	else:
		itemfol.hide()
	
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
			itemattr.text += value[key]
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
			itemattr.text += value[stat]
			i+=1
	else:
		itemattr.text = ""

func update_price():
	popup_pollen.add_color_override("font_color",Color.white)
	popup_fol.add_color_override("font_color",Color.white)
	popup_accept.disabled = false
	pricepol= stackgui* DataImport.item_data[presseditem][type_market+"pl"]
	pricefol= stackgui* DataImport.item_data[presseditem][type_market+"fol"]
	popup_pollen.text = "Pollen: "+str(pricepol)
	popup_fol.text = "FoL: "+str(pricefol)
	
	if pricepol <= 0:
		popup_pollen.hide()
	elif pricepol > pollen:
		popup_pollen.show()
		if type_market == "buy":
			popup_pollen.add_color_override("font_color",Color.red)
	else:
		popup_pollen.show()
		if type_market == "buy":
			popup_pollen.add_color_override("font_color",Color.white)
		
	if pricefol <= 0:
		popup_fol.hide()
	elif pricefol > fol:
		popup_fol.show()
		if type_market == "buy":
			popup_fol.add_color_override("font_color",Color.red)
	else:
		popup_fol.show()
		if type_market == "buy":
			popup_fol.add_color_override("font_color",Color.white)
	if type_market == "buy":
		if (pricepol <= pollen and pricefol <= fol):
			popup_accept.disabled = false
		else:
			popup_accept.disabled = true
		
func on_item_toggled(node):
	if is_instance_valid(togglenode):
		if node == togglenode:
			togglenode.set_pressed(false)
			itemattr.text = "Attribute: "
			togglenode = null
			conf_button()
			desccontainer.hide()
			welcomecontainer.show()
		else:
			togglenode.set_pressed(false)
			togglenode = node
			presseditem = togglenode.name_item
			set_infoitem()
			conf_button()
			desccontainer.show()
			welcomecontainer.hide()
	else:
		togglenode = node
		presseditem = togglenode.name_item
		set_infoitem()
		conf_button()
		desccontainer.show()
		welcomecontainer.hide()

func _on_Buy_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	type_market="buy"
	openingcontainer.hide()
	secondcontainer.show()
	var text
	if rand_range(0,100) < 5:
		text = "My dream is only to find my lost sister with this money I collected"
	elif rand_range(0,100) < 50:
		text = "My spirit will never run out to trade throughout the city"
	elif rand_range(0,100) < 75:
		text = "I will open my shop on many place in this world!"
	else:
		text = "Pick your item and buy many as you want!"
	labelwelcome.text="Welcome to Myrid Merchant Shop!\n"+text
	var i=0
	while i < max_slot:
		var node = Global.instance_node(item_slot)
		Global.spawn_node_deferred(node,itemcontainer)
		node.connect("item_toggled",self,"on_item_toggled")
		list_item.push_back(node)
		i += 1
	update_inventory(item_buy)
	optionbutton.text = "Buy"

func _on_Sell_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	type_market="sell"
	openingcontainer.hide()
	secondcontainer.show()
	var text
	if rand_range(0,100) < 15:
		text = "Hey I like antiques! Bring the antique to me!"
	elif rand_range(0,100) < 50:
		text = "Do you know? All of today's adventurous goods are sold out! So just sell it here."
	elif rand_range(0,100) < 75:
		text = "I hope your day is very beautiful today. So maybe you sell a lot today."
	else:
		text = "Sell your item here! Whatever it is!"
	labelwelcome.text="Welcome to Myrid Merchant Shop!\n"+text
	var i=0
	while i < max_slot:
		var node = Global.instance_node(item_slot)
		Global.spawn_node_deferred(node,itemcontainer)
		node.connect("item_toggled",self,"on_item_toggled")
		list_item.push_back(node)
		i += 1
	update_inventory(item_sell)
	optionbutton.text = "Sell"

func _on_Back_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	openingcontainer.hide()
	npc_event.process_complete = true
	get_tree().paused=false
	gui.get_node("Minimap").show()
	queue_free()
	get_tree().call_group("Game","set_interactnpc",false)
	pass # Replace with function body.

func _on_Option_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if type_market == "buy":
		popupcontainer.show()
		popup_tag.text = "Buy Item"
		popup_itemname.text = DataImport.item_data[presseditem].real_name
		popup_itemcount.text = "1"
		stackgui = 1
		stack = 128
		update_price()
	if type_market == "sell":
		popupcontainer.show()
		popup_tag.text = "Sell Item"
		popup_itemname.text = DataImport.item_data[presseditem].real_name
		popup_itemcount.text = "1"
		stackgui = 1
		stack = item_sell[presseditem].stack
		update_price()

func _on_LineEdit_text_change_rejected():
	popup_itemcount.text=str(1)
	stackgui = 1
	update_price()

func _on_Up_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.INVENTORYSELECT)
	if stackgui >= stack:
		popup_itemcount.set_text("1")
		stackgui = 1
	else:
		stackgui += 1
		popup_itemcount.set_text(str(stackgui))
	update_price()

func _on_Down_button_down():
	MusicSystem.set_sfx(MusicSystem.ui.INVENTORYDESELECT)
	if stackgui <= 1:
		popup_itemcount.set_text(str(stack))
		stackgui = stack
	else:
		stackgui -= 1
		popup_itemcount.set_text(str(stackgui))
	update_price()
#	if stackgui* DataImport.item_data[presseditem][type_market] >= pollen:

func _on_LineEdit_text_entered(new_text):
	if new_text.is_valid_integer() :
		if int(new_text) <= 1:
			popup_itemcount.set_text("1")
		stackgui = int(new_text)
	else:
		popup_itemcount.set_text(str(stack))
		stackgui = stack
	update_price()

func _on_Cancel_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	popupcontainer.hide()
	pass # Replace with function body.

func _on_Back2_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	secondcontainer.hide()
	openingcontainer.show()
	togglenode = null
	presseditem = null
	for list in list_item:
		list.queue_free()
	list_item.clear()
	pass # Replace with function body.

func _on_Accept_pressed():
	if type_market=="buy":
		if (pricepol <= pollen and pricefol <= fol):
			MusicSystem.set_sfx(MusicSystem.ui.SHOPACTION)
			var text = "You has been buy "+DataImport.item_data[presseditem].real_name+" "+str(stackgui)+" pcs"
			if pricepol > 0:
				text += " "+str(pricepol) + " pollen"
			if pricefol > 0:
				text += " "+str(pricefol) + " FoL"
			Global.create_alert(text)
			world.add_item(presseditem,stackgui)
			countbuy +=stackgui
			world.stats_game["pollen"]=pollen-pricepol
			world.stats_game["fol"]=fol-pricefol
			pollen=world.stats_game["pollen"]
			fol=world.stats_game["fol"]
	else:
		if stackgui <= stack:
			MusicSystem.set_sfx(MusicSystem.ui.SHOPACTION)
			world.stats_game["pollen"]=pollen+pricepol
			world.stats_game["fol"]=fol+pricefol
			pollen=world.stats_game["pollen"]
			fol=world.stats_game["fol"]
			world.set_invstack(presseditem,-1*stackgui)
			togglenode.set_stack(item_sell[presseditem].stack)
			var list=list_item.find(togglenode)
			if !world.inventory.has(presseditem):
				list_item.remove(list)
				togglenode.queue_free()
				var node = Global.instance_node(item_slot)
				Global.spawn_node(node,itemcontainer)
				node.connect("item_toggled",self,"on_item_toggled")
				list_item.push_back(node)
				togglenode = null
				presseditem = "none"
				conf_button()
				desccontainer.hide()
				welcomecontainer.show()
			update_inventory(item_sell)
	set_price()
	popupcontainer.hide()
	pass # Replace with function body.


func _on_BtnSFX_mouse_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)
