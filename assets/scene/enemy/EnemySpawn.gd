extends Node2D

onready var area_spawn = $CollisionShape2D

export (Array) var enemy_group
export (int) var max_enemy = 5
export (int) var spawner_id = 1
var count_enemy = 0
var valid_enemy
var path_nav

func _ready():
	$PivotSpawn.position=Vector2(rand_range(-area_spawn.shape.extents.x,area_spawn.shape.extents.x),rand_range(-area_spawn.shape.extents.y,area_spawn.shape.extents.y))
	randomize()
	add_to_group("spawner"+str(spawner_id))

func is_enemy_death():
	count_enemy -= 1
#	print ("spawner"+str(spawner_id)+" : "+str(count_enemy))
#	yield(get_tree().create_timer(3),"timeout")
#	spawn_enemy_randomly()

func spawn_enemy_randomly():
	randomize()
	var name_enemy = enemy_group[randi()%enemy_group.size()]
	var loadenemy = load("res://assets/scene/enemy/main_system/Enemy.tscn")
	var node_enemy=Global.instance_node(loadenemy)
	var stat_enemy = node_enemy.get_node("Stats")
	node_enemy.enemy = name_enemy 
	node_enemy.node_name = DataImport.enemy_data[name_enemy].node_name
	node_enemy.is_range = DataImport.enemy_data[name_enemy].is_range
	node_enemy.global_position = $PivotSpawn.global_position
	node_enemy.path_nav = path_nav
	node_enemy.spawner = spawner_id
	node_enemy.xp = DataImport.enemy_data[name_enemy].exp
	node_enemy.not_attack = bool(int(DataImport.enemy_data[name_enemy].not_attack))
	node_enemy.equip_bullet = DataImport.enemy_data[name_enemy].bullet
	stat_enemy.attack =  DataImport.enemy_data[name_enemy].attack
	stat_enemy.defense = DataImport.enemy_data[name_enemy].defense
	stat_enemy.knockback = DataImport.enemy_data[name_enemy].knockback
	stat_enemy.attack_speed = DataImport.enemy_data[name_enemy].attack_speed
	stat_enemy.speed=DataImport.enemy_data[name_enemy].speed
	stat_enemy.maxhp= DataImport.enemy_data[name_enemy].maxhp
	stat_enemy.hp= DataImport.enemy_data[name_enemy].maxhp
#	if DataImport.enemy_data[name_enemy].skill != "none":
#		var skill =DataImport.enemy_data[name_enemy].skill.split(",",true,0)
#		node_enemy.skill = skill
	Global.spawn_node(node_enemy,get_parent())
	count_enemy+=1
	$PivotSpawn.position=Vector2(rand_range(-area_spawn.shape.extents.x,area_spawn.shape.extents.x),rand_range(-area_spawn.shape.extents.y,area_spawn.shape.extents.y))

func _on_SpawnTime_timeout():
	if count_enemy < max_enemy :
		spawn_enemy_randomly()


func _on_PivotSpawn_body_entered(_body):
	$PivotSpawn.position=Vector2(rand_range(-area_spawn.shape.extents.x,area_spawn.shape.extents.x),rand_range(-area_spawn.shape.extents.y,area_spawn.shape.extents.y))


func _on_PivotSpawn_area_entered(_area):
	$PivotSpawn.position=Vector2(rand_range(-area_spawn.shape.extents.x,area_spawn.shape.extents.x),rand_range(-area_spawn.shape.extents.y,area_spawn.shape.extents.y))
	pass # Replace with function body.
