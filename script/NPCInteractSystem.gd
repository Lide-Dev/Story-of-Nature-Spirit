extends Node

enum type{
	SINGLE,
	BRANCH,
	OPTION
}

enum status{
	IDLE,
	PROCESS
}

var alias_name
var name_npc = ""
var path_img ="none"
var id_dialog = ""
var option:Array
var type_interact = type.SINGLE
var custom_value = ""
var custom_classification = ""
var callback = []
var bye
var greeting
var item_merchant=[]
var item_buy = {}
##=================================
var resource
var interact_status = status.IDLE
var text
var dialog
var game
var optionselect
var process_complete = false
var questsystem
var questcomplete = false
var current_obj
var quest_response = false
var quest_option = []
var quest_callback = []
var quest_list = []
var quest_available

func _ready():
	add_to_group("InteractSystem")
	var node=get_tree().get_nodes_in_group("Dialog")
	dialog = node[0]
	game = get_tree().get_root().get_node("Game")

func get_interact_status():
	return interact_status

func set_interact(npc,path,id,type,opti=[],custom_val="",custom_class=""):
	name_npc=npc
	path_img=path
	id_dialog=id
	custom_value = custom_val
	custom_classification = custom_class
	option = opti.duplicate()
	type_interact=type
	print("Name: "+name_npc+"type"+str(type)+",path: "+path_img+",id: "+id_dialog+"custom_val:"+custom_value+"custom_class:"+custom_class)
	interact_start()

func quest_interact():
	var n = get_tree().get_nodes_in_group("World")
	var world = n[0]
	n=get_tree().get_nodes_in_group("QuestSystem")
	questsystem=n[0]
	if quest_available.size() > 0:
		for value in quest_available:
			var q =  DataImport.quest_data[value]
			if (world.level >= int(q.require.lv) and questsystem.completemain_count >= int(q.require.main_complete)):
				if (questsystem.main_quest.has(value) ||questsystem.opti_quest.has(value)):
					quest_option.push_back(q.name + " (Accepted)")
					quest_callback.push_back("accepted")
					quest_list.push_back(value)
				elif (questsystem.maincomplete_quest.has(value)||questsystem.opticomplete_quest.has(value)):
					continue
				else:
					quest_option.push_front(q.name)
					quest_callback.push_front("add_quest")
					quest_list.push_front(value)
	quest_option.push_front("Response")
	quest_callback.push_front("response")
	quest_option.push_back("Cancel")
	quest_callback.push_back("cancelquest")
	callback = quest_callback
	set_interact("System","none","custom",type.OPTION,quest_option,"Quest Selection","")

func interact_start():
	match type_interact:
		type.SINGLE:
			print("SINGLE")
			if id_dialog == "custom":
				text = custom_value
			else:
				if custom_classification == "":
					text=DataImport.npc_data[id_dialog].dialog
				else:
					text=DataImport.npc_data[id_dialog].dialog[custom_classification][0]
			dialog.set_dialog(name_npc,text,path_img,true)
			game.interact_npc = true
		type.BRANCH:
			var classification
			print("BRANCH")
			if custom_classification == "":
				classification = DialogClassification.classification[id_dialog].talk
			else:
				classification = custom_classification
			var size = DataImport.npc_data[id_dialog].dialog[classification].size()
			text=DataImport.npc_data[id_dialog].dialog[classification][randi()%size]
			dialog.set_dialog(name_npc,text,path_img,true)
			game.interact_npc = true
		type.OPTION:
			print("OPTION")
			var classification
			if id_dialog == "custom":
				text=custom_value
			else:
				if custom_classification == "":
					classification = DialogClassification.classification[id_dialog].talk
				else:
					classification = custom_classification
				var size = DataImport.npc_data[id_dialog].dialog[classification].size()
				text=DataImport.npc_data[id_dialog].dialog[classification][randi()%size]
			dialog.set_option_dialog(name_npc,text,option,path_img)
#			set_option_dialog(namenpc,text,option:Array,path_picture="none")
			game.interact_npc = true
	interact_process()
	$Timer.start(0.3)

func interact_process():
	get_tree().call_group("Game","set_interactnpc",true)
	interact_status = status.PROCESS
	game.interact_npc = true
	pass

func interact_finished():
	get_tree().call_group("Game","set_interactnpc",false)
	quest_option = []
	quest_callback = []
	game.interact_npc = false
	name_npc = ""
	path_img ="none"
	id_dialog = ""
	interact_status = status.IDLE
	option.clear()
	$Timer.stop()
	type_interact = type.SINGLE
	custom_value = ""
	custom_classification = ""

func quest_classification():
	if !current_obj["complete"]:
		match current_obj["type"]:
			"interact":
				set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"])
				questcomplete = true
			"delivery_interact":
				if current_obj["item"]["current"]>=current_obj["item"]["stack"]:
					questsystem.delivery_item(current_obj["item"]["name"],int(current_obj["item"]["stack"]))
					set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_accept")
					questcomplete = true
				else:
					set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_cancel")
			"stat_interact":
				var n = get_tree().get_nodes_in_group("World")
				var world = n[0]
				var realval
				var value = current_obj["stat"]["require"][1]
				var condition = current_obj["stat"]["require"][0]
				var val 
				if value.find_last("%") >= 0:
					value.replace("%","")
					var m = world.stats.get(current_obj["stat"]["maxname"])
					var v = world.stats.get(current_obj["stat"]["name"])
					realval = (v/m) * 100
					val = m*(int(value)/100)
				else:
					val = int(value)
				match condition:
					"lt":
						if realval < value:
							questsystem.delivery_stat(current_obj["stat"]["name"],val)
							set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_accept")
							questcomplete = true
						else:
							set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_cancel")
					"gt":
						if realval > float(value):
							questsystem.delivery_stat(current_obj["stat"]["name"],val)
							set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_accept")
							questcomplete = true
						else:
							set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_cancel")
	else:
		set_interact("System","none","custom",type.SINGLE,[],"There is no quest on here","")

func quest_checkinteract():
	var n=get_tree().get_nodes_in_group("QuestSystem")
	name_npc = DataImport.npc_data[resource.alias_name].name
	alias_name=resource.alias_name
	path_img= "res://assets/img/character/npc/"+resource.alias_name+".png"
	questsystem=n[0]
	current_obj =questsystem.get_objinteract(alias_name)
	if typeof(current_obj) == TYPE_DICTIONARY:
		if typeof(current_obj["need_obj"]) == TYPE_STRING:
			quest_classification()
		else:
			var arr_valid = []
			for c in current_obj["need_obj"]:
				var valid = false
				var obj_q = questsystem.obj_quest
				for o in obj_q:
					if (o["id"] == current_obj["id"] and int(o["objid"])==int(c)):
						if o["complete"]:
							valid = true
							break
				arr_valid.push_back(valid)
			if arr_valid.has(false):
				set_interact(name_npc,path_img,alias_name,type.SINGLE,[],"",current_obj["response"]+"_cancel")
			else:
				quest_classification()
	else:
		set_interact("System","none","custom",type.SINGLE,[],"There is no quest on here","")

func _on_Timer_timeout():
	if !dialog.dialog_show:
		if process_complete:
			process_complete=false
			get_tree().paused = false
			set_interact(name_npc,path_img,id_dialog,type.BRANCH,[],"","bye")
			callback = resource.greeting_callback
		if type_interact == type.OPTION:
			name_npc = DataImport.npc_data[resource.alias_name].name
			alias_name=resource.alias_name
			path_img= "res://assets/img/character/npc/"+resource.alias_name+".png"
			optionselect=dialog.optionselect
			match callback[optionselect]:
				"talk":
					set_interact(name_npc,path_img,id_dialog,type.BRANCH,[],"","")
				"shop":
					type_interact = type.BRANCH
					var pathopen = load("res://assets/scene/UI/MerchantUI.tscn")
					var node =Global.instance_node(pathopen)
					for arr in item_merchant:
						item_buy[arr]={"stack":128}
					node.item_buy = item_buy
					node.npc_event = self
					var gui = get_node("/root/Game/GUI")
					Global.spawn_node_deferred(node,gui)
				"quest":
					quest_interact()
				"cancel":
					if bye:
						MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
						set_interact(name_npc,path_img,id_dialog,type.BRANCH,[],"","bye")
						interact_finished()
				"response":
					print("response")
					quest_checkinteract()
				"accepted":
					set_interact("System","none","custom",type.SINGLE,[],"Quest already accepted.","")
				"complete":
					set_interact("System","none","custom",type.SINGLE,[],"Quest has been completed!.","")
				"cancelquest":
					print("cancelquest")
					var path = "res://assets/img/character/npc/"+resource.alias_name+".png"
					callback = resource.greeting_callback
					set_interact(
						name_npc,
						path,
						resource.alias_name,
						type.OPTION,
						resource.greeting_option,
						"",
						"greet")
				"add_quest":
					set_interact("System","none","custom",type.SINGLE,[],"Still being Constructed!.","")
		else:
			interact_finished()
		if questcomplete:
			questsystem.set_objcomplete(current_obj)
			questcomplete = false
		
	else:
		interact_process()
	
