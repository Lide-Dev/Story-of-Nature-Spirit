extends Control

onready var texturequestleft = $UIQuestRight/ColorRect2
onready var questwelcome = $QuestWelcome
onready var questlist = $QuestList
onready var questfirst = $QuestButton
onready var questdesc = $QuestDesc
onready var list = $QuestList/ScrollContainer/VBox
onready var emptylist =$QuestList/ScrollContainer/VBox/Empty
onready var objlist = $QuestDesc/Objective/VBox/ObjectiveList
onready var rewardlist = $QuestDesc/Objective/VBox/RewardList

onready var label_questlist = $QuestList/Label
onready var label_title = $QuestDesc/Description/VBox/TitleValue
onready var label_citylocation = $QuestDesc/Description/VBox/LocationValue
onready var label_npc = $QuestDesc/Description/VBox/NPCValue
onready var label_lv = $QuestDesc/Description/VBox/LvValue
onready var label_desc = $QuestDesc/Description/VBox/DescValue

onready var btn_mainquest = $QuestButton/MainQuest
onready var btn_optiquest = $QuestButton/OptiQuest
onready var btn_backlist = $QuestList/Back
onready var dummy_btnquest = $QuestList/ScrollContainer/VBox/Dummy
onready var dummy_objcomplete = $QuestDesc/Objective/VBox/ObjectiveList/Complete
onready var dummy_objactive = $QuestDesc/Objective/VBox/ObjectiveList/Active
onready var dummy_objdeactive = $QuestDesc/Objective/VBox/ObjectiveList/Deactive
var quest
var type_quest
var current_quest = []
var complete_quest = []
var btncurrentlist = []
var btncompletelist = []
var labelobjlist = []
var objarr = []
var btn_toggle
var desc_type

func _ready():
	add_to_group("QuestGUI")

func show_questlist():
	questfirst.hide()
	questlist.show()
	var node = get_tree().get_nodes_in_group("QuestSystem")
	quest = node[0]
	var new_arr1
	var new_arr2
	var new_arr3
	if type_quest == "main":
		new_arr1 = quest.get_quest("main")
		new_arr2 = quest.get_quest("mcomplete")
	else:
		new_arr1 = quest.get_quest("opti")
		new_arr2 = quest.get_quest("ocomplete")
	new_arr3 = quest.get_quest("obj")
	current_quest = new_arr1.duplicate()
	objarr = new_arr3.duplicate()
	complete_quest = new_arr2.duplicate()
	if current_quest.size() > 0:
		emptylist.hide()
		for arr in current_quest:
			var newbtn = dummy_btnquest.duplicate(8)
			newbtn.text = DataImport.quest_data[arr].name
			list.add_child(newbtn)
			newbtn.show()
			newbtn.connect("pressed",self,"on_CurQuestButtonPress",[newbtn])
			btncurrentlist.push_back(newbtn)
	else:
		emptylist.show()
		
	if complete_quest.size() > 0:
		emptylist.hide()
		for arr in complete_quest:
			var newbtn =dummy_btnquest.duplicate(8)
			newbtn.text = DataImport.quest_data[arr].name
			list.add_child(newbtn)
			newbtn.show()
			newbtn.set("custom_colors/font_color",Color("ebad19"))
			newbtn.connect("pressed",self,"on_ComQuestButtonPress",[newbtn])
			btncompletelist.push_back(newbtn)

func hide_questlist():
	if btncurrentlist.size() >0:
		for btn in btncurrentlist:
			btn.queue_free()
	if btncompletelist.size() >0:
		for btn in btncompletelist:
			btn.queue_free()
	if labelobjlist.size() >0:
		for lbl in labelobjlist:
			lbl.queue_free()
	btncurrentlist = []
	btncompletelist = []
	labelobjlist = []
	emptylist.show()
	questlist.hide()
	questfirst.show()

func show_desc(id,index):
	print("Desc ID Quest: "+str(id)+", Index: "+str(index))
	questwelcome.hide()
	texturequestleft.hide()
	questdesc.show()
	label_title.text = DataImport.quest_data[id].name
	label_npc.text = DataImport.quest_data[id].npc
	label_citylocation.text =  DataImport.quest_data[id].at_city+", "+ DataImport.quest_data[id].at_location
	label_desc.text = DataImport.quest_data[id].desc
	label_lv.text = "Lv. "+ DataImport.quest_data[id].level
	if desc_type == "current":
		for arr in objarr:
			if arr["id"] != id:
				break
			var newlabel
			if arr["complete"]:
				newlabel = dummy_objcomplete.duplicate(8)
				newlabel.text="> "+arr["desc"]+" (Completed)"
				objlist.add_child(newlabel)
				newlabel.show()
			elif arr["unlock"]:
				var text =""
				match arr["type"]:
					"interact":
						text = ""
					"delivery_interact":
						text = " ("+str(arr["item"]["current"])	+"/"+str(arr["item"]["stack"])+")"
					"stat_interact":
						text = " ("+str(arr["stat"]["current"])	+"/"+str(arr["stat"]["require"][1])+")"
				newlabel = dummy_objactive.duplicate(8)
				newlabel.text="> "+arr["desc"]+text
				objlist.add_child(newlabel)
				newlabel.show()
			else:
				newlabel = dummy_objdeactive.duplicate(8)
				newlabel.text="> Locked"
				objlist.add_child(newlabel)
				newlabel.show()
			labelobjlist.push_back(newlabel)
	else:
		var a = DataImport.quest_data[id].obj_desc
		for arr in a:
			var newlabel
			newlabel = dummy_objcomplete.duplicate(8)
			newlabel.text="> "+arr+" (Completed)"
			objlist.add_child(newlabel)
			newlabel.show()
			labelobjlist.push_back(newlabel)

func hide_desc():
	questwelcome.show()
	texturequestleft.show()
	questdesc.hide()
	label_title.text = ""
	label_npc.text = ""
	label_citylocation.text =  ""
	label_desc.text = ""
	label_lv.text = ""
	if labelobjlist.size() >0:
		for lbl in labelobjlist:
			lbl.queue_free()
		labelobjlist = []

func _on_MainQuest_pressed():
	label_questlist.text = "Main Quest"
	type_quest = "main"
	show_questlist()

func _on_OptiQuest_pressed():
	label_questlist.text = "Optional Quest"
	type_quest = "opti"
	show_questlist()

func on_CurQuestButtonPress(btn):
	if btn_toggle == btn:
		hide_desc()
		btn_toggle.pressed=false
		btn_toggle=null
	else:
		hide_desc()
		var index = btncurrentlist.find(btn)
		if is_instance_valid(btn_toggle):
			btn_toggle.pressed = false
			btn_toggle = null
		btn_toggle=btn
		btn_toggle.pressed = true
		desc_type = "current"
		show_desc(current_quest[index],index)

func on_ComQuestButtonPress(btn):
	if btn_toggle == btn:
		hide_desc()
		btn_toggle.pressed=false
		btn_toggle=null
	else:
		hide_desc()
		var index = btncompletelist.find(btn)
		if is_instance_valid(btn_toggle):
			btn_toggle.pressed = false
			btn_toggle = null
		btn_toggle=btn
		btn_toggle.pressed = true
		desc_type = "complete"
		show_desc(complete_quest[index],index)

func _on_Back_pressed():
	hide_questlist()
	hide_desc()
	btn_toggle=null
	pass # Replace with function body.
