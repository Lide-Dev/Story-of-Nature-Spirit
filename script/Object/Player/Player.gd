extends KinematicBody2D
#
#signal hp_changed(hp)
#signal pp_changed(pp)
#signal wp_changed(wp)
#signal mhp_changed(mhp)
#signal mpp_changed(mpp)
signal interact_item(key)

const MAX_SPEED = 100
const FRICTION = 10
const ACCELERATION = 10

enum {
	MOVE,
	CAST,
	DEATH,
	REGEN,
	LOADING,
	IDLE,
}

var water_interact
var npc_interact
var bullet_instance
var can_fire = true
var velocity = Vector2.ZERO
var state = IDLE
var eknockback = Vector2.ZERO
var game_root
var skilltree
var mouse_position
var stats
var death
var interactinfo
var maximunwater= false
onready var sfx_regen = $AudioStreamPlayer2D
onready var pointer = $CastPoint
onready var outBullet = $CastPoint/Position2D
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
#onready var stats = get_node("Stats")
onready var castbar = $CastBar
onready var marker = preload("res://assets/scene/Effect/MarkerBullet.tscn")
onready var head_skin = $Sprite/Head/Accessories_Head
onready var orb1_skin = $Sprite/OrbL/Accessories_OrbL
onready var orb2_skin = $Sprite/OrbR/Accessories_OrbR


func _ready():
	add_to_group("player")
	get_tree().call_group("mark_system","node_added",self,"player")
	game_root= get_tree().get_root().get_node("Game/World")
	animationTree.active = true
	skilltree = game_root.skilltree

func get_skillvalue(key):
	if skilltree.has(key):
		return skilltree[key].value*skilltree[key].lvl
	else:
		return 0

func _process(_delta):
	if state == CAST:
		castbar.value = castbar.max_value-$CastTime.time_left
	pointer.look_at(get_global_mouse_position())
	if pointer.rotation_degrees > 360:
		pointer.rotation_degrees=0
	if pointer.rotation_degrees < 0:
		pointer.rotation_degrees=360
	if npc_interact != null :
		$Interact.cast_to=npc_interact.global_position-global_position
	else:
		$Interact.cast_to=Vector2(0,0)

func _unhandled_input(event):
	if (event.is_action_pressed("ui_attack") and can_fire and state != DEATH and state != REGEN):
		var reducewp = (DataImport.bullet_data[game_root.equipBullet].cost_wp*get_skillvalue("WaterFlow"))
		var reducepp = (DataImport.bullet_data[game_root.equipBullet].cost_pp*get_skillvalue("PowderFlow"))
		if stats.wp < DataImport.bullet_data[game_root.equipBullet].cost_wp+reducewp:
			Global.create_alert("Not enough Water")
		elif stats.pp < DataImport.bullet_data[game_root.equipBullet].cost_pp+reducepp:
			Global.create_alert("Not enough Powder")
		else:
			stats.wp -= DataImport.bullet_data[game_root.equipBullet].cost_wp+reducewp
			stats.pp -= DataImport.bullet_data[game_root.equipBullet].cost_pp+reducepp
			maximunwater = false
			input_attack()
		percentinteract_info((stats.wp/stats.maxhp*100))
		
	
	if (event.is_action_pressed("ui_water") and water_interact and state != CAST and state !=DEATH):
		if state==REGEN:
			sfx_regen.playing = false 
			state = MOVE
			percentinteract_info((stats.wp/stats.maxhp*100))
			process_regen(false)
		else:
			var res = MusicSystem.get_music(MusicSystem.effect.REGENWATER)
			percentinteract_info((stats.wp/stats.maxhp*100))
			process_regen(true)
			sfx_regen.stream = res
			sfx_regen.playing = true 
			state = REGEN

func _physics_process(delta):
	match state:
		IDLE:
			move_state(delta)
			eknockback = eknockback.move_toward(Vector2.ZERO, stats.knockback_acc * delta)
			eknockback = move_and_slide(eknockback)
		MOVE:
			move_state(delta)
			eknockback = eknockback.move_toward(Vector2.ZERO, stats.knockback_acc * delta)
			eknockback = move_and_slide(eknockback)
		CAST:
			attack_state()
			eknockback = eknockback.move_toward(Vector2.ZERO, stats.knockback_acc * delta)
			eknockback = move_and_slide(eknockback)
		DEATH:
			pass
		REGEN:
			regen_state()
		LOADING:
			velocity=Vector2.ZERO

func move_state(_delta):
	if state != DEATH:
		var input_vector = Vector2.ZERO
#		var mouse_vector = Vector2.ZERO
		
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		input_vector = input_vector.normalized()
		
		
		if input_vector != Vector2.ZERO:
			state = MOVE
			animationTree.set("parameters/Idle/blend_position",input_vector)
			animationTree.set("parameters/Run/blend_position",input_vector)
			animationState.travel("Run")
			velocity = velocity.move_toward(input_vector*stats.speed, stats.speed/10)
		else:
			state = IDLE
			animationState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
		velocity = move_and_slide(velocity)

func attack_state():
	animationState.travel("Cast")

func attack_finished():
	animationState.travel("Casting")

func input_attack():
	var mouse_vector = Vector2.ZERO
	if pointer.rotation_degrees > 330 or pointer.rotation_degrees < 60:
		mouse_vector = Vector2(1,0)
	if pointer.rotation_degrees > 60 and pointer.rotation_degrees < 150:
		mouse_vector = Vector2(0,1)
	if pointer.rotation_degrees > 150 and pointer.rotation_degrees < 240:
		mouse_vector = Vector2(-1,0)
	if pointer.rotation_degrees > 240 and pointer.rotation_degrees < 330:
		mouse_vector = Vector2(0,-1)
	mouse_vector.normalized()
	
	if mouse_vector != Vector2.ZERO:
		animationTree.set("parameters/Cast/blend_position",mouse_vector)
		animationState.set("parameters/Casting/blend_position",mouse_vector)
	
	mouse_position = get_global_mouse_position()
	can_fire = false
	state = CAST
	$CastTime.start(DataImport.bullet_data[game_root.equipBullet].cast_time)
	castbar.max_value=DataImport.bullet_data[game_root.equipBullet].cast_time
	MusicSystem.set_sfx2d(MusicSystem.effect.CASTINGWATER,self,true)
	castbar.show()
	var mark=Global.instance_node(marker,mouse_position)
	mark.start = DataImport.bullet_data[game_root.equipBullet].cast_time
	Global.spawn_node(mark,get_tree().get_root())

func regen_state():
#	animationPlayer.play("Regen")
	animationState.travel("Regen")
	pass

func bullet_spawn(equipBullet = "WaterShot"):
	var knockback_vector = Vector2.ZERO
	knockback_vector = (mouse_position - global_position).normalized()
	var index = 3
	if pointer.rotation_degrees > 180 and pointer.rotation_degrees < 360:
		index = 2
	bullet_instance = load("res://assets/scene/Effect/"+DataImport.bullet_data[game_root.equipBullet].type+".tscn")
	var bullet=Global.instance_node(bullet_instance,outBullet.get_global_position())
	bullet.addSpeed = DataImport.bullet_data[game_root.equipBullet].projectile_speed * get_skillvalue("EnergySpread")
	bullet.rotation = get_angle_to(mouse_position)
	bullet.z_index = index
	bullet.attack = stats.attack
	bullet.bullet = equipBullet
	bullet.knockback_vector = knockback_vector
	bullet.cast_time = 0#stats.delay_attack
	get_tree().get_root().add_child(bullet)

func fdeath():
	interact_info("interact",false)
	percentinteract_info((stats.wp/stats.maxhp*100))
	process_regen(false)
	interact_info("regen",false)
	sfx_regen.playing = false
	state= DEATH
	hide()
	$Hurtbox.set_deferred("monitorable",false)
	$Hurtbox.set_deferred("monitoring",false)
	var death_path = load("res://assets/scene/CharDeath.tscn")
	death=Global.instance_node(death_path,get_global_position())
	death.anim = "player"
	Global.spawn_node(death,get_tree().get_root())
#	yield(get_tree().create_timer(2),"timeout")
#	queue_free()
func effect_equipment():
	var res_head
	var res_orb1
	var res_orb2
	if game_root.equipment.head != "":
		print("Head added!")
		var head = DataImport.equip_data[game_root.equipment.head]
		res_head =load("res://assets/scene/player/cosmetic/"+head.skin+".tres")
	else:
		res_head =load("res://assets/scene/player/cosmetic/NoneHead.tres")
	if game_root.equipment.orb1 != "":
		var orbl = DataImport.equip_data[game_root.equipment.orb1]
		res_orb1 = load("res://assets/scene/player/cosmetic/"+orbl.skin+"_L.tres")
	else:
		res_orb1 =load("res://assets/scene/player/cosmetic/NoneOrb.tres")
	if game_root.equipment.orb2 != "":
		var orbr = DataImport.equip_data[game_root.equipment.orb2]
		res_orb2 = load("res://assets/scene/player/cosmetic/"+orbr.skin+"_R.tres")
	else:
		res_orb2 =load("res://assets/scene/player/cosmetic/NoneOrb.tres")
	
	head_skin.frames = res_head
	orb1_skin.frames = res_orb1
	orb2_skin.frames = res_orb2

func revive():
	state= MOVE
	show()
	$Hurtbox.set_deferred("monitorable",true)
	$Hurtbox.set_deferred("monitoring",true)
	death.queue_free()

func interact_info(type,value):
	var a = get_tree().get_nodes_in_group("InteractInfo")
	interactinfo=a[0]
	if type == "interact":
		interactinfo.show_interactinfo(value)
	else:
		interactinfo.show_regeninfo(value)
	
func percentinteract_info(value):
	var a = get_tree().get_nodes_in_group("InteractInfo")
	interactinfo=a[0]
	interactinfo.set_percent(value)
	
func process_regen(value):
	var a = get_tree().get_nodes_in_group("InteractInfo")
	interactinfo=a[0]
	interactinfo.process_regen(value)

func damaged_calc(area):
	var obj = area.get_owner()
	var eknockback_vector=(global_position - obj.global_position).normalized()
	if obj.get_class() != "RigidBody2D":
		var statsenemy = obj.get_node("Stats")
		var timer = obj.get_node("ValidAttack")
		if obj.validAttack:
			obj.validAttack = false
			timer.start(statsenemy.attack_speed)
			yield(get_tree().create_timer(statsenemy.delay_attack),"timeout")
			var get_area
			if !is_instance_valid(area):
				pass
			else:
				get_area = area.get_overlapping_areas()
				if !get_area.empty():
					$Sprite.modulate = Color("ec6363")
					var splash = load("res://assets/scene/Effect/BulletSplash.tscn")
					splash=Global.instance_node(splash)
					splash.z_index = 3
					splash.bullet = "MeleeEffect"
#					var map = get_tree().get_nodes_in_group("MapManager")
					Global.spawn_node(splash,self)
					print("Enemy attack: "+ str(statsenemy.attack))
					var calc=Global.melee_damage(self,statsenemy,skilltree["WaterProtector"].toggled,get_skillvalue("WaterProtector"))
					print("Your HP "+ str(stats.hp))
					eknockback = eknockback_vector*statsenemy.knockback
					Global.create_txt_damage(self.global_position,calc,stats.maxhp)
					area.set_deferred("monitorable",false)
					MusicSystem.set_sfx2d(MusicSystem.effect.MELEEHURT,self)
				else:
					Global.create_txt_damage(self.global_position,"Miss",1)
		else:
			print("Enemy attack: Cooldown")
	else:
		$Sprite.modulate = Color("ec6363")
		print("Enemy attack: "+ str(obj.attack))
		var calc =Global.bullet_damage(self,obj,skilltree["WaterProtector"].toggled,get_skillvalue("WaterProtector"))
		print("Your HP "+ str(stats.hp))
		eknockback = eknockback_vector*obj.knockback
		MusicSystem.set_sfx2d(MusicSystem.effect.MELEEHURT,self)
	if state == REGEN:
		percentinteract_info((stats.wp/stats.maxhp*100))
		process_regen(false)
		state = MOVE
		sfx_regen.playing = false
	yield(get_tree().create_timer(0.5),"timeout")
	$Sprite.modulate = Color("ffffff")


func _on_CastTime_timeout():
	castbar.hide()
	state=MOVE
	bullet_spawn(game_root.equipBullet)
	$FireRate.start(stats.delay_attack)

func _on_InteractArea_body_entered(body):
	npc_interact = body
	if npc_interact.get_collision_layer_bit(11):
		print("Interact with NPC "+str(npc_interact))
		interact_info("interact",true)
	else:
		print("Interact with Item "+str(npc_interact))
		emit_signal("interact_item",body.name_item)
		get_tree().call_group("logtext","set_text","You got "+DataImport.item_data[body.name_item].real_name+"!")
		MusicSystem.set_sfx2d(MusicSystem.effect.GETITEM,self)
		body.queue_free()
		

func _on_InteractArea_body_exited(_body):
	npc_interact=null
	interact_info("interact",false)
	pass # Replace with function body.

func _on_WaterRegen_body_entered(body):
	if body.get_collision_layer_bit(15) == true:
		water_interact = true
		interact_info("regen",true)
		percentinteract_info((stats.wp/stats.maxhp*100))

func _on_WaterRegen_body_exited(body):
	if body.get_collision_layer_bit(15) == true:
		water_interact = false
		interact_info("regen",false)
		percentinteract_info((stats.wp/stats.maxhp*100))
		process_regen(false)

func _on_FireRate_timeout():
	can_fire = true

func _on_Hurtbox_area_entered(area):
	if area.get_owner().get_class() != "YSort":
		damaged_calc(area)

func _on_Stats_no_health():
	fdeath()
	get_tree().get_root().get_node("Game").death = true
	 # Replace with function body.

func _on_PerSecond_timeout():
	if state != DEATH:
		var pp:float = stats.pp
		pp += float(stats.fertility)*(0.01+get_skillvalue("NaturalEnergy"))
		if pp <= stats.maxpp:
			stats.pp = pp
		else:
			stats.pp = stats.maxpp
		
		if (state==MOVE && stats.wp > 0):
			var wp:float = stats.wp
			wp -= float(stats.ratiowaterdec*stats.maxhp) 
			print(stats.ratiowaterdec)
			print(stats.ratiowaterdec*stats.maxhp)
			if wp <= 0:
				stats.wp = 0
			else:
				stats.wp = wp
				maximunwater = false
		
		if state==REGEN:
				
			var wp = stats.wp
			wp += stats.maxhp*(0.2+get_skillvalue("LiftingWater"))
			if wp <= stats.maxhp:
				stats.wp = wp
				maximunwater = false
			else:
				if !maximunwater :
					stats.wp = stats.maxhp
					maximunwater = true
				else :
					stats.wp = wp
					state = DEATH
					stats.hp = 0
			percentinteract_info((stats.wp/stats.maxhp*100))
			process_regen(true)
	pass # Replace with function body.

