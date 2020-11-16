extends Node2D

export (String) var name_skill = ""
export (bool) var is_player = false
export (float) var cast_time = 0
export (bool) var automate = false
export (float) var automate_time = 0
export (int) var summon_size = 1
export (String,"Mobs","Item","Bullet") var type_summon = "Mobs"
export (String) var summon_idvalue = ""
export (bool) var bullet_rotate
export (float) var lifespan = 0
var cast_timer
var automate_timer
var path_nav
var parent
var player

func _ready():
	print("Skill Summon ready")
	match type_summon:
		"Mobs":
			print("Summon Mobs")
			if DataImport.enemy_data.has(summon_idvalue):
				var parent = get_parent()
				path_nav = parent.get_node(parent.nodeNav).get_path()
				init_config()
				print("Init Completed")
			else:
				if Global.development:
					print ("Error: Summon not available for id: "+summon_idvalue+" with type "+type_summon)
		"Item":
			pass
		"Bullet":
			parent = get_parent().enemy_parent
			var node = get_tree().get_nodes_in_group("player")
			player = node[0]
			init_config()

func on_cast_finished():
	pass

func on_automate_finished():
	match type_summon:
		"Mobs":
			print("Mobs Summon")
			summon_mobs(summon_idvalue)
		"Bullet":
			parent = get_parent().enemy_parent
			if is_instance_valid(player):
				summon_bullet(player,bullet_rotate)

func init_config():
	if cast_time > 0:
		cast_timer = Timer.new()
		Global.spawn_node(cast_timer,self)
		cast_timer.wait_time = cast_time
		cast_timer.one_shot = true
		cast_timer.connect("timeout",self,"on_cast_finished")
	if automate:
		if automate_time > 0:
			automate_timer = Timer.new()
			Global.spawn_node(automate_timer,self)
			automate_timer.one_shot = false
			automate_timer.start(automate_time)
			automate_timer.connect("timeout",self,"on_automate_finished")

func summon_mobs(name_enemy):
	var loadenemy = load("res://assets/scene/enemy/main_system/Enemy.tscn")
	var node_enemy=Global.instance_node(loadenemy)
	var stat_enemy = node_enemy.get_node("Stats")
	node_enemy.enemy = name_enemy 
	node_enemy.node_name = DataImport.enemy_data[name_enemy].node_name
	node_enemy.is_range = DataImport.enemy_data[name_enemy].is_range
	node_enemy.global_position = global_position
	node_enemy.path_nav = path_nav
	node_enemy.spawner = 404
	node_enemy.xp = DataImport.enemy_data[name_enemy].exp
	node_enemy.not_attack = bool(int(DataImport.enemy_data[name_enemy].not_attack))
	node_enemy.lifespan = lifespan
	node_enemy.equip_bullet = DataImport.enemy_data[name_enemy].bullet
	stat_enemy.attack =  DataImport.enemy_data[name_enemy].attack
	stat_enemy.defense = DataImport.enemy_data[name_enemy].defense
	stat_enemy.knockback = DataImport.enemy_data[name_enemy].knockback
	stat_enemy.attack_speed = DataImport.enemy_data[name_enemy].attack_speed
	stat_enemy.speed=DataImport.enemy_data[name_enemy].speed
	stat_enemy.maxhp= DataImport.enemy_data[name_enemy].maxhp
	stat_enemy.hp= DataImport.enemy_data[name_enemy].maxhp
	var map = get_tree().get_nodes_in_group("mapqueue")
	map[0].call_deferred("add_child",node_enemy)

func summon_bullet(player,is_rotat:bool):
	var knockback_vector = Vector2.ZERO
	knockback_vector = Vector2(1,0).rotated(get_angle_to(player.global_position))
	var bullet_instance = load("res://assets/scene/Effect/"+DataImport.bullet_data[summon_idvalue].type+".tscn")
	var bullet=Global.instance_node(bullet_instance)
	bullet.z_index = 3
	if is_rotat:
		bullet.rotation = get_angle_to(player.global_position)
	bullet.is_player = false
	bullet.attack = parent.stats.attack
	bullet.bullet = summon_idvalue
	bullet.knockback_vector = knockback_vector
#	sprite.animation = "attack"
	bullet.cast_time = DataImport.bullet_data[summon_idvalue].cast_time 
	bullet.global_position = get_parent().enemy_parent.outputBullet.global_position
	var map = get_tree().get_nodes_in_group("MapManager")
	map[0].call_deferred("add_child",bullet)
