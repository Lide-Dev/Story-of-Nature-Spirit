extends Node

var main_quest = []
var opti_quest = []
var maincomplete_quest = []
var opticomplete_quest = []
var obj_quest = []
var is_newgame= false
var completemain_count = 0
var world

func _ready():
	add_to_group("QuestSystem")
	if is_newgame:
		main_quest.push_back("tutorial1")
		submit_obj("tutorial1")

func load_game(value):
	var keys = value.keys()
	for key in keys:
		set(key,value[key])

func add_quest(id,type):
	match type:
		"main":
			main_quest.push_back(id)
		"opti":
			opti_quest.push_back(id)
	submit_obj(id)

func get_completecount():
	return completemain_count

func get_quest(type):
	match type:
		"main":
			return main_quest
		"opti":
			return opti_quest
		"mcomplete":
			return maincomplete_quest
		"ocomplete":
			return opticomplete_quest
		"obj":
			return obj_quest

func get_objinteract(npc):
	print ("Get "+npc+" in objective")
	var index = 0
	var valid = false
	for arr in obj_quest:
		var k=arr.keys()
		print(k)
		if k.has("npc"):
			print("Search Objective interact index-"+str(index))
			if arr["response"] == "none":
				continue
			if arr["npc"] == npc:
				valid = true
				print("Objective interact valid npc")
				break
		index+= 1
	if valid:
		return obj_quest[index]
	else:
		print("Objective interact invalid npc")
		return valid
#		check_task(obj_quest[index])

func delivery_item(item,stack):
	world.set_invstack(item,-stack)

func delivery_stat(stat,quantity):
	match stat:
		"pollen":
			world.stats_game.pollen -= quantity
		"xp":
			world.set_xp(world.xp- quantity)
		"fol":
			world.stats_game.fol -= quantity
		_:
			world.stats.set(stat,world.stats.get(stat)-int(quantity))

func init_item(item):
	var stck
	stck= world.inventory.get(item,0)
	if typeof(stck)==TYPE_INT:
		return stck
	else:
		return stck["stack"]

func init_stat(stat):
	match stat:
		"xp":
			return world.xp
		"pollen":
			return world.stats_game["pollen"]
		"fol":
			return world.stats_game["fol"]
		"wp":
			var wp
			var m
			wp = world.stats.get(stat)
			m = world.stats.get("maxhp")
			return wp/m*100
		_:
			return world.stats.get(stat)
	
	

func update_item(item,stack):
	for obj in obj_quest:
		match obj["type"]:
			"delivery_interact":
				if obj["item"]["name"] == item:
					obj["item"]["current"] = stack
			"loot":
				if obj["item"]["name"] == item:
					obj["item"]["current"] = stack
					if obj["item"]["current"] >= int(obj["item"]["stack"]):
						set_objcomplete(obj)

func update_stat(stat,quantity):
	for obj in obj_quest:
		if obj["type"]=="stat_interact":
			if obj["stat"]["name"] == stat:
				obj["stat"]["current"] = quantity

func delete_obj(id):
	var i = 0
	var arr = []
	for obj in obj_quest:
		if obj["id"] == id:
			arr.push_back(i)
		i += 1
	for a in arr:
		obj_quest[a] = "none"
	for a in arr:
		obj_quest.erase("none")

func set_objcomplete(arr_objquest):
	var n = get_tree().get_nodes_in_group("player")
	var player = n[0]
	var arr = arr_objquest
	var index = obj_quest.find(arr)
	print("Get Index "+str(index))
	if index >= 0:
		get_tree().call_group("logtext","set_text",DataImport.quest_data[obj_quest[index]["id"]].name+" "+str(int(obj_quest[index]["objid"]+1))+" : Objective Completed!")
		obj_quest[index]["complete"]= true
		var indexunlock =DataImport.quest_data[arr["id"]].completed_unlock[index]
		print("Index Unlock "+str(indexunlock))
		reward_quest(obj_quest[index]["id"],index)
		if str(indexunlock) == "none":
			MusicSystem.set_sfx(MusicSystem.ui.QUESTCOMPLETE)
			print("Quest Complete")
			var id_quest=obj_quest[index]["id"]
			var i =main_quest.find(id_quest)
			print("INDEX QUEST REMOVED "+str(i))
			if i >= 0:
				main_quest.remove(i)
				maincomplete_quest.push_back(obj_quest[i]["id"])
				completemain_count +=1
			i =opti_quest.find(id_quest)
			if i >= 0:
				opti_quest.remove(i)
				opticomplete_quest.push_back(obj_quest[i]["id"])
			delete_obj(id_quest)
			get_tree().call_group("logtext","set_text",DataImport.quest_data[arr["id"]].name+" : Quest Complete!")
			Global.create_txt(player.global_position,"Quest Completed!")
		else:
			for obj in obj_quest:
				if (obj["id"] == obj_quest[index]["id"] ):
					if (typeof(indexunlock) == TYPE_ARRAY):
						for i in indexunlock:
							if obj["objid"]==i:
								MusicSystem.set_sfx(MusicSystem.ui.OBJCOMPLETE)
								print("Objective Complete")
								obj["unlock"]=true
								get_tree().call_group("logtext","set_text",DataImport.quest_data[obj["id"]].name+" "+str(int(obj["objid"]+1))+" : Objective Complete!")
								Global.create_txt(player.global_position,"Quest Completed!")
					else:
						if obj["objid"]==indexunlock:
							MusicSystem.set_sfx(MusicSystem.ui.OBJCOMPLETE)
							print("Objective Complete")
							obj["unlock"]=true
							get_tree().call_group("logtext","set_text",DataImport.quest_data[obj["id"]].name+" "+str(int(obj["objid"]+1))+" : Objective Unlocked!")
							Global.create_txt(player.global_position,"Quest Completed!")
					
					
func reward_quest(id,index_obj):
	var reward=DataImport.quest_data[id].reward[index_obj]
	var key=reward.keys()
	for k in key:
		if k == "xp":
			world.set_xp(world.xp+int(reward[k]))
			get_tree().call_group("logtext","set_text","Get +"+str(reward[k])+" XP!")
		elif k == "pollen":
			world.stats_game["pollen"] += int(reward[k])
			get_tree().call_group("logtext","set_text","Get +"+str(reward[k])+" Pollen!")
		elif k == "fol":
			world.stats_game["fol"] += int(reward[k])
			get_tree().call_group("logtext","set_text","Get +"+str(reward[k])+" Flower of Light!")
		elif k == "quest":
			var text
			if DataImport.quest_data[reward[k]].type == "main":
				text = "Main"
				add_quest(reward[k],"main")
			else:
				text = "Optional"
				add_quest(reward[k],"opti")
			get_tree().call_group("logtext","set_text","Get "+text+" Quest: "+DataImport.quest_data[reward[k]].name+" !")
		elif k == "none":
			pass
		else:
			world.add_item(k,int(reward[k]))
			get_tree().call_group("logtext","set_text","Get "+DataImport.item_data[k].real_name+" "+str(reward[k])+" Pcs!")

func submit_obj(id):
#	var is_change = false
#	if obj_quest.has(id):
#		is_change = true
	var obj_type = DataImport.quest_data[id].obj_type
	var i = 0
	for obj in obj_type:
		var descobj = DataImport.quest_data[id].obj_desc[i]
		var need_obj = DataImport.quest_data[id].obj_task[i].need_obj
		match obj:
			"interact":
				var npc = DataImport.quest_data[id].obj_task[i].npc
				var city = DataImport.quest_data[id].obj_task[i].city
				var location = DataImport.quest_data[id].obj_task[i].location
				var is_unlock = bool(int(DataImport.quest_data[id].init_unlock[i]))
				var response_npc = DataImport.quest_data[id].obj_task[i].response
				obj_quest.push_back(
					{
						"objid":i,
						"npc":npc,
						"city":city,
						"location":location,
						"unlock":is_unlock,
						"complete":false,
						"type":obj,
						"id":id,
						"desc":descobj,
						"response": response_npc,
						"need_obj":need_obj
					}
				)
			"delivery_interact":
				var npc = DataImport.quest_data[id].obj_task[i].npc
				var city = DataImport.quest_data[id].obj_task[i].city
				var location = DataImport.quest_data[id].obj_task[i].location
				var item = DataImport.quest_data[id].obj_task[i].item
				var stack= DataImport.quest_data[id].obj_task[i].stack
				var is_unlock = bool(int(DataImport.quest_data[id].init_unlock[i]))
				var response_npc = DataImport.quest_data[id].obj_task[i].response
				obj_quest.push_back(
					{
						"objid":i,
						"npc":npc,
						"city":city,
						"location":location,
						"item":{"name":item,"stack":stack,"current":init_item(item)}, 
						"unlock":is_unlock,
						"complete":false,
						"type":obj,
						"id":id,
						"desc":descobj,
						"response":response_npc,
						"need_obj":need_obj
						}
				)
			"loot":
				var item = DataImport.quest_data[id].obj_task[i].item
				var stack= DataImport.quest_data[id].obj_task[i].stack
				var is_unlock = bool(int(DataImport.quest_data[id].init_unlock[i]))
				obj_quest.push_back(
					{
						"objid":i,
						"item":{"name":item,"stack":stack,"current":init_item(item)},
						"unlock":is_unlock,
						"complete":false,
						"type":obj,
						"id":id,
						"desc":descobj,
						"need_obj":need_obj
					}
				)
			"stat_interact":
				var npc = DataImport.quest_data[id].obj_task[i].npc
				var city = DataImport.quest_data[id].obj_task[i].city
				var location = DataImport.quest_data[id].obj_task[i].location
				var stat = DataImport.quest_data[id].obj_task[i].stat
				var maxstat = DataImport.quest_data[id].obj_task[i].maxstat
				var require= DataImport.quest_data[id].obj_task[i].require
				var is_unlock = bool(int(DataImport.quest_data[id].init_unlock[i]))
				var response_npc = DataImport.quest_data[id].obj_task[i].response
				obj_quest.push_back(
					{
						"objid":i,
						"npc":npc,
						"city":city,
						"location":location,
						"stat":{"name":stat,"require":require,"current":init_stat(stat),"maxname":maxstat}, 
						"unlock":is_unlock,
						"complete":false,
						"type":obj,
						"id":id,
						"desc":descobj,
						"response":response_npc,
						"need_obj":need_obj
					}
				)
			"travel":
				var city = DataImport.quest_data[id].obj_task[i].city
				var location = DataImport.quest_data[id].obj_task[i].location
				var is_unlock = bool(int(DataImport.quest_data[id].init_unlock[i]))
				var response_npc = DataImport.quest_data[id].obj_task[i].response
				obj_quest.push_back({
					"objid":i,
					"city":city,
					"location":location,
					"position":[float(DataImport.quest_data[id].obj_task[i].position[0]),float(DataImport.quest_data[id].obj_task[i].position[1])],
					"area":[float(DataImport.quest_data[id].obj_task[i].area[0]),float(DataImport.quest_data[id].obj_task[i].area[1])],
					"id":id,
					"unlock":is_unlock,
					"complete":false,
					"type":obj,
					"desc":descobj,
					"response":response_npc,
					"need_obj":need_obj
				})
		i += 1
	
