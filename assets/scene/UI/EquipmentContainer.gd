extends Control

onready var welcome_container = $ScrollContainer/Control/Welcome
onready var description_container = $ScrollContainer/Control/Description
onready var name_value = $ScrollContainer/Control/Description/Name
onready var type_value = $ScrollContainer/Control/Description/Type
onready var description = $ScrollContainer/Control/Description/Description
onready var grid_stat = $ScrollContainer/Control/Description/GridContainer
onready var stat_value = $ScrollContainer/Control/Description/GridContainer/Stat
onready var head_box = $EquipBox/GridEquip/EquipHead
onready var orb1_box = $EquipBox/GridEquip/EquipOrb1
onready var orb2_box = $EquipBox/GridEquip/EquipOrb2
onready var ring_box = $EquipBox/GridEquip/EquipRing
onready var head_btn = $EquipBox/GridEquip/EquipHead/Button
onready var orb1_btn = $EquipBox/GridEquip/EquipOrb1/Button
onready var orb2_btn = $EquipBox/GridEquip/EquipOrb2/Button
onready var ring_btn = $EquipBox/GridEquip/EquipRing/Button
onready var head_skin = $Position2D/Sprite/Head
onready var orb1_skin = $Position2D/Sprite/OrbR
onready var orb2_skin = $Position2D/Sprite/OrbL
onready var find_btn = $EquipBox/VBoxContainer/Find
onready var unequip_btn = $EquipBox/VBoxContainer/Unequip
var menu

var stat_data = ["maxhp","maxpp","luck","attack","defense","speed","soil","slip","fert","bullet"]
var stat_name = ["MaxHP","MaxPP","Luck","Attack","Defense","Speed","Soil","Slippery","Fertility","Bullet"]
var stat_labellist = []
var anim_rotate = ["IdleDown","IdleLeft","IdleUp","IdleRight"]
var anim_index = 0
var btn_toggle
var equip_list = {"head":"","orb1":"","orb2":"","ring":""}
var pressed_item = ""
var pressed_key
var world
var stat

func _ready():
	head_box.connect("item_toggled",self,"equip_toggled")
	orb1_box.connect("item_toggled",self,"equip_toggled")
	orb2_box.connect("item_toggled",self,"equip_toggled")
	ring_box.connect("item_toggled",self,"equip_toggled")
	var n = get_tree().get_nodes_in_group("World")
	world=n[0]
	equip_list=world.equipment
	print(equip_list)
	stat=world.stats
	conf_skin()
	conf_box()
	conf_anim()

func conf_skin():
	var res_head
	var res_orb1
	var res_orb2
	var res_ring
	if equip_list.head != "":
		print("Head added!")
		var head = DataImport.equip_data[equip_list.head]
		res_head =load("res://assets/scene/player/cosmetic/"+head.skin+".tres")
	else:
		res_head =load("res://assets/scene/player/cosmetic/NoneHead.tres")
	if equip_list.orb1 != "":
		var orbr = DataImport.equip_data[equip_list.orb1]
		res_orb1 = load("res://assets/scene/player/cosmetic/"+orbr.skin+"_L.tres")
	else:
		res_orb1 =load("res://assets/scene/player/cosmetic/NoneOrb.tres")
	if equip_list.orb2 != "":
		var orbl = DataImport.equip_data[equip_list.orb2]
		res_orb2 = load("res://assets/scene/player/cosmetic/"+orbl.skin+"_R.tres")
	else:
		res_orb2 =load("res://assets/scene/player/cosmetic/NoneOrb.tres")
	
	head_skin.frames = res_head
	orb1_skin.frames = res_orb1
	orb2_skin.frames = res_orb2

func conf_box():
	if equip_list.head!="":
		head_box.set_nameitem(equip_list.head)
	else:
		head_box.set_nameitem("None")
		
	if equip_list.orb1!="":
		orb1_box.set_nameitem(equip_list.orb1)
	else:
		orb1_box.set_nameitem("None")
	
	if equip_list.orb2!="":
		orb2_box.set_nameitem(equip_list.orb2)
	else:
		orb2_box.set_nameitem("None")
	
	if equip_list.ring!="":
		ring_box.set_nameitem(equip_list.ring)
	else:
		ring_box.set_nameitem("None")

func conf_anim():
	$AnimationPlayer.play(anim_rotate[anim_index])

func conf_desc():
	if pressed_item != "":
		var item = DataImport.item_data[pressed_item]
		var equip = DataImport.equip_data[pressed_item]
		name_value.text = item.real_name
		type_value.text = equip.type.capitalize()
		description.text = item.description
		conf_stat()
	else:
		for st in stat_labellist:
			st.queue_free()
		stat_labellist=[]

func conf_stat():
	var i = 0
	var equip = DataImport.equip_data[pressed_item]
	for stat in stat_data:
		var newstat
		print(stat)
		if str(equip[stat]) != "0":
			print("VALID:"+stat)
			if str(equip[stat]).is_valid_integer() :
				newstat = stat_value.duplicate(8)
				stat_labellist.push_back(newstat)
				$ScrollContainer/Control/Description/GridContainer.add_child(newstat)
				if int(equip[stat]) < 0:
					newstat.text = str(equip[stat])+" "+stat_name[i]
				else:
					newstat.text = "+"+str(equip[stat])+" "+stat_name[i]
			elif stat_data[i] == "bullet":
				if equip[stat]!="none":
					newstat = stat_value.duplicate(8)
					stat_labellist.push_back(newstat)
					newstat.text = "Get "+DataImport.bullet_data[equip[stat]].call_name+" Bullet"
					$ScrollContainer/Control/Description/GridContainer.add_child(newstat)
			else:
				newstat = stat_value.duplicate(8)
				stat_labellist.push_back(newstat)
				$ScrollContainer/Control/Description/GridContainer.add_child(newstat)
				if float(equip[stat]) < 0:
					newstat.text = str(equip[stat] *  100)+"% "+stat_name[i]
				else:
					newstat.text = "+"+str(equip[stat] * 100)+"% "+stat_name[i]
				
			if str(equip[stat]) !="none":
				newstat.show()
		
		i+=1

func equip_toggled(btn):
	if is_instance_valid(btn_toggle):
		if btn_toggle == btn:
			btn_toggle.set_pressed(false)
			btn_toggle = null
			pressed_item = ""
			pressed_key = ""
			description_container.hide()
			welcome_container.show()
			unequip_btn.disabled=true
		else:
			btn_toggle.set_pressed(false)
			btn_toggle = btn
			pressed_item = btn_toggle.name_item
			pressed_key = btn_toggle.key
			btn_toggle.set_pressed(true)
			description_container.show()
			welcome_container.hide()
			unequip_btn.disabled=false
	else:
		btn_toggle = btn
		btn_toggle.set_pressed(true)
		pressed_item = btn_toggle.name_item
		pressed_key = btn_toggle.key
		description_container.show()
		welcome_container.hide()
		unequip_btn.disabled=false
	conf_desc()

func _on_Left_pressed():
	if (anim_index-1)< 0:
		anim_index = 3
	else:
		anim_index -= 1
	conf_anim()

func _on_Right_pressed():
	if (anim_index+1)> 3:
		anim_index = 0
	else:
		anim_index += 1
	conf_anim()

func _on_Find_pressed():
	menu._on_Inventory_pressed()

func _on_Unequip_pressed():
	if equip_list[pressed_key] == pressed_item:
		equip_list[pressed_key]=""
		world.set_equipment(pressed_key,"")
	world.add_item(pressed_item,1)
	btn_toggle.set_nameitem("None")
	btn_toggle.set_pressed(false)
	btn_toggle = null
	pressed_item = ""
	description_container.hide()
	welcome_container.show()
	unequip_btn.disabled=true
	conf_box()
	conf_skin()
	conf_desc()
	pass # Replace with function body.
