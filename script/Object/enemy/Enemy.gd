extends KinematicBody2D

export (bool) var is_range = false
export (bool) var not_attack = false
export (String) var enemy = "Worm"
export (String) var equip_bullet = "SmellCloud"

onready var stats = get_node("Stats")
onready var wanderControl = $WanderControl
onready var ValidAttack = $ValidAttack
onready var bodyCollision = $CollisionShape2D
onready var outputBullet = $Out/OutBullet
onready var outputCenter = $Out
onready var MAX_SPEED = stats.speed
onready var ACCELERATION = stats.speed
onready var FRICTION = 60
var bullet_instance
var worldnode
var node_name
var nodeNav
var destination
var knockback = Vector2.ZERO  #knockbacknya
var velocity = Vector2.ZERO
var path : = PoolVector2Array()
var validAttack = true setget set_valid_attack
var attackRange = 4
var hurtbox
var hitbox
var radiusHate 
var playerDetection
var timerHate 
var sprite
var replicaCollision
var replicaOutputBullet
var orihate = CircleShape2D.new()
var path_nav
var spawner
var xp = 0
var lifespan = 0
var lifespanbar
var lifetimer

enum {
	IDLE,
	WANDER,
	CHASE,
	DEATH
}
var state = IDLE
# Called when the node enters the scene tree for the first time.
func debug():
	if is_instance_valid(outputCenter):
		print("Node OutBullet Added: "+str(outputCenter)+" on parent "+str(outputCenter.get_parent().get_name()))
	else:
		print("Node Outbullet Failed")
	if is_instance_valid(wanderControl):
		print("Node Wander Control Added: "+str(wanderControl))
		print(" on parent "+str(wanderControl.get_parent().get_name()))
	else:
		print("Node Wander Control Failed")
	if is_instance_valid(stats):
		print("Node Stats Added: "+str(stats))
		print(" on parent "+str(stats.get_parent().get_name()))
	else:
		print("Node Stats Failed")
	playerDetection =get_node(node_name+"/EnemyDetection")
	if is_instance_valid(playerDetection):
		print("Node Player Detection Added: "+str(playerDetection))
		print(" on parent "+str(playerDetection.get_parent().get_name()))
		print(" on parentparent "+str(playerDetection.get_parent().get_parent().get_name()))

func _ready():
	add_to_group("enemies")
	var group = get_tree().get_nodes_in_group("World")
	worldnode = group[0]
	get_tree().call_group("mark_system","node_added",self,"enemy")
	var loadenemy = load("res://assets/scene/enemy/"+node_name+".tscn")
	var n=Global.instance_node(loadenemy)
	print("Ready: "+str(self))
	if is_instance_valid(n):
		Global.spawn_node(n,self)
		print("Node Enemy Spawned "+str(n)+" on parent "+str(n.get_parent().get_name()))
	else:
		get_tree().call_group("spawner"+str(spawner),"is_enemy_death")
		queue_free()
		print("Node Enemy Failed")
	debug()
	hitbox = get_node(node_name+"/Hitbox")
	hurtbox = get_node(node_name+"/Hurtbox")
	get_node(node_name).path_nav = path_nav
	var enemyn=get_node(node_name)
	enemyn.enemy_parent = self
	if is_range :
		hitbox.monitorable = false
		attackRange = hitbox.get_node("CollisionShape2D").shape.radius
	ValidAttack.start(stats.attack_speed)
	nodeNav = get_tree().get_root().get_node(path_nav)
#	line= get_tree().get_root().get_node("Game/World/Line2D")
#	print(nodeNav)
	get_node(node_name).set_maxhp_bar(stats.hp,stats.maxhp)
	replicaCollision = get_node(node_name+"/CollisionBody/Collision") 
	replicaOutputBullet = get_node(node_name+"/Output") 
	radiusHate = get_node(node_name+"/EnemyDetection/CollisionShape2D")
	playerDetection =get_node(node_name+"/EnemyDetection")
	timerHate = get_node(node_name+"/EnemyDetection/Hate")
	sprite = get_node(node_name+"/Sprite")
	state = pick_random_state([IDLE,WANDER])
	orihate.set_radius(radiusHate.shape.radius)
#	timerHate.connect("timeout",self,"_on_Hate_timeout")
	if (is_range):
		hitbox.connect("area_entered",self,"_on_Hitbox_area_entered")
		
	hurtbox.connect("area_entered",self,"_on_Hurtbox_area_entered")
	sprite.connect("animation_finished",self,"_on_Sprite_animation_finished")
	var new_circle = CapsuleShape2D.new()
	new_circle.set_radius(replicaCollision.shape.radius)
	new_circle.set_height(replicaCollision.shape.height)
	bodyCollision.shape = new_circle
	bodyCollision.rotation = replicaCollision.rotation
	bodyCollision.position = replicaCollision.position
	outputBullet.global_position = replicaOutputBullet.global_position
	if lifespan > 0 :
		lifetimer = Timer.new()
		add_child(lifetimer)
		lifetimer.start(lifespan)
		lifetimer.connect("timeout",self,"on_Lifespan_timeout")
		lifespanbar=Global.instance_node(load("res://assets/scene/enemy/main_system/Lifespan.tscn"))
		Global.spawn_node(lifespanbar,self)
		lifespanbar= lifespanbar.get_node("Lifespan")
		lifespanbar.max_value = lifespan
		lifespanbar.value = lifespan
#	if skill.size() > 0:
#		for val in skill:
#			var trigger = DataImport.state_data[val].state_trigger
#			activeskill[trigger].push_back(val)
#	skill_passive()


func _process(delta):
	if is_instance_valid(lifetimer):
		lifespanbar.value = lifetimer.time_left
#	if !is_instance_valid(wanderControl):
#		_on_Stats_no_health()
#	if !is_instance_valid(playerDetection):
#		_on_Stats_no_health()
	if !is_instance_valid(outputCenter):
		print("Node OutBullet FREED on parent "+str(get_parent().get_name()))
	if !is_instance_valid(wanderControl):
		print("Node Wander Control FREED on parent "+str(get_parent().get_name()))
	if !is_instance_valid(stats):
		print("Node Stats Freed on parent "+str(get_parent().get_name()))

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, stats.knockback_acc * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, (stats.speed/2)*delta)
			seek_player()
			if is_instance_valid(wanderControl):
				if wanderControl.get_time_wander()<=0:
					update_wander()
		
		WANDER:
			seek_player()
			if is_instance_valid(wanderControl):
				if wanderControl.get_time_wander()<=0:
					update_wander()
			acceleration_towards_point(wanderControl.target_position,delta, true)
			if is_instance_valid(wanderControl):
				if global_position.distance_to(wanderControl.target_position)<= 4:
					update_wander()
			
		CHASE:
			var player = playerDetection.player
			var move_distance = (stats.speed-(stats.speed/10))* delta
		
			if (player != null and !not_attack):
				var distance =  global_position - player.global_position 
				#print(distance.x)
				if is_range:
					if (distance.x > 0):
						destination = player.global_position - Vector2(-attackRange,distance.y)
					elif (distance.x < 0):
						destination = player.global_position - Vector2(attackRange,distance.y)
					else:
						destination = global_position
				else:
					destination = player.global_position
				var start = global_position
				path = nodeNav.get_simple_path(start, destination,false)
#				if is_range:
#					line.points = path
# warning-ignore:unused_variable
				for point in range(path.size()):
					var next = start.distance_to(path[0])
					if move_distance <= next:
						var move_rotation = get_angle_to(start.linear_interpolate(path[0], move_distance/ next))
						if !validAttack:
							if is_range:
								if distance.x > attackRange or distance.x < -attackRange:
									velocity = Vector2(0,0).rotated(move_rotation)
								else:
									velocity = Vector2(stats.speed-(stats.speed/10),0).rotated(move_rotation)
							else:
								if distance.x > attackRange or distance.x < -attackRange:
									velocity = Vector2(stats.speed-(stats.speed/10),0).rotated(move_rotation)
								else:
									velocity = Vector2(0,0).rotated(move_rotation)
						else:
							velocity = Vector2(stats.speed-(stats.speed/10),0).rotated(move_rotation)
						break
					move_distance -= next
					start = path[0]
					path.remove(0)
				acceleration_towards_point(player.global_position, delta, false)
			else:
				state=IDLE
			
	
	velocity = move_and_slide(velocity)


func set_valid_attack(valid):
	validAttack = valid
	if valid == false:
		sprite.animation = "attack"

func acceleration_towards_point(point,delta, wander):
	var direction = global_position.direction_to(point)
	if wander:
		velocity = velocity.move_toward(direction*MAX_SPEED, stats.speed-(stats.speed/10) *delta)
		
	sprite.flip_h =  velocity.x < 0
	if velocity.x < 0:
		hitbox.scale = Vector2(-1,1)
		outputCenter.scale = Vector2(-1,1)
		hurtbox.scale= Vector2(-1,1)
	else:
		hitbox.scale = Vector2(1,1)
		outputCenter.scale = Vector2(1,1)
		hurtbox.scale= Vector2(1,1)

func update_wander():
	state = pick_random_state([IDLE,WANDER])
	match DataImport.enemy_data[enemy].wander:
		"high":
			wanderControl.wander_range = 100
			wanderControl.start_timer_wander(rand_range(1,2))
		"normal":
			wanderControl.wander_range = 70
			wanderControl.start_timer_wander(rand_range(2,4))
		"low":
			wanderControl.wander_range = 50
			wanderControl.start_timer_wander(rand_range(3,6))
	#print(state)

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func seek_player():
	if is_instance_valid(playerDetection):
		if playerDetection.can_see_player():
			state = CHASE

func bullet_out(player,rot=true):
	var knockback_vector = Vector2.ZERO
	knockback_vector = Vector2(1,0).rotated(get_angle_to(player.global_position))
	
	bullet_instance = load("res://assets/scene/Effect/"+DataImport.bullet_data[equip_bullet].type+".tscn")
	var bullet=Global.instance_node(bullet_instance)
	bullet.z_index = 3
	if rot:
		bullet.rotation = get_angle_to(player.global_position)
	bullet.is_player = false
	bullet.attack = stats.attack
	bullet.bullet = equip_bullet
	bullet.knockback_vector = knockback_vector
	sprite.frame = 0
	if !not_attack:
		sprite.animation = "attack"
	bullet.cast_time = DataImport.bullet_data[equip_bullet].cast_time 
	bullet.global_position = outputBullet.global_position
	var map = get_tree().get_nodes_in_group("MapManager")
	map[0].call_deferred("add_child",bullet)
#
#func skill_passive():
#	if activeskill["passive"].size()> 0:
#		for val in activeskill["passive"]:
#			match DataImport.state_data[val].state:
#				"bulletps":
#					$BulletPerTime.start(stats.attack_speed)

func _on_Hurtbox_area_entered(area):
	var obj = area.get_parent()
	print("Your attack: "+ str(obj.attack))
# warning-ignore:unused_variable
	var calc =Global.bullet_damage(self,obj)
	knockback = obj.knockback_vector * obj.knockback
	timerHate.start(4)
	var new_circle = CircleShape2D.new()
	new_circle.set_radius(orihate.radius*2)
	radiusHate.shape = new_circle
	MusicSystem.set_sfx2d(MusicSystem.effect.RANGEHURT,self)

func _on_Stats_no_health():
	remove_from_group("enemies")
	worldnode.xp += xp
#	radiusHate.shape.radius = radiusOriginal
	if spawner != 404:
		get_tree().call_group("spawner"+str(spawner),"is_enemy_death")
	get_tree().call_group("spawner_ysort","item_drop",enemy,global_position)
	get_tree().call_group("spawner_ysort","spawn_enemydeath",global_position,sprite.flip_h,enemy)
	queue_free()

func _on_ValidAttack_timeout():
	validAttack=true;
	if !is_range:
		hitbox.set_deferred("monitorable",true)
	else:
		hitbox.set_deferred("monitoring",true)
	pass # Replace with function body.


func _on_Hitbox_area_entered(area):
	if !not_attack:
		if is_range:
			var player = area.get_parent()
			bullet_out(player)
			if player.position.x > self.position.x:
				sprite.flip_h = false
				hitbox.scale = Vector2(-1,1)
				outputBullet.scale = Vector2(-1,1)
			else:
				sprite.flip_h = true
				hitbox.scale = Vector2(1,1)
				outputBullet.scale = Vector2(1,1)
			
			validAttack= false
			ValidAttack.start(stats.attack_speed)
			hitbox.set_deferred("monitoring",false)
	pass # Replace with function body.

func _on_Sprite_animation_finished():
	if sprite.animation == "attack":
		sprite.animation = "move"
	pass # Replace with function body.

func on_Lifespan_timeout():
	remove_from_group("enemies")
	queue_free()

