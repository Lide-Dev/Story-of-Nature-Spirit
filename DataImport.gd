extends Node

var bullet_data = {
}

var enemy_data={
}

var item_data={
}

var state_data={
}

var stateparameter_data={
}

var npc_data={
	
}

var quest_data={
	
}

var equip_data={
	
}

var skill_data={
	
}

var city_data= {}

var path_bullet = "res://data/BulletData.dat"
var path_enemy = "res://data/EnemyData.dat"
var path_item = "res://data/ItemData.dat"
var path_state = "res://data/StateData.dat"
var path_stateparameter = "res://data/StateParameterData.dat"
var path_npc = "res://data/NPCData.dat"
var path_quest = "res://data/QuestData.dat"
var path_equip = "res://data/EquipData.dat"
var path_city = "res://data/CityData.dat"
var path_skill = "res://data/SkillData.dat"

func _ready():
	bullet_data = get_json(path_bullet)
	enemy_data = get_json(path_enemy)
	item_data = get_json(path_item)
	state_data = get_json(path_state)
	stateparameter_data = get_json(path_stateparameter)
	npc_data = get_json(path_npc)
	quest_data = get_json(path_quest)
	equip_data = get_json(path_equip)
	city_data = get_json(path_city)
	skill_data = get_json(path_skill)

func get_json(path):
	var data_file = File.new()
#	dir_contents("res://data")
	if !(data_file.file_exists(path)):
		print("NILL");
	data_file.open(path, File.READ)
	var json = JSON.parse(data_file.get_as_text())
	data_file.close()
	var data = json.result
	return data

func dir_contents(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
