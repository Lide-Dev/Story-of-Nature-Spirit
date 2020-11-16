extends RigidBody2D

export (bool) var is_aoe = false
var cast_time = 0
var bullet = "WaterShot"
var addSpeed = 0
var multiplier = 0
var attack = 0
var knockback = 0
var speed = 200
var velocity = Vector2.ZERO
var knockback_vector = Vector2.ZERO
var splash= false
var is_player = true
var splasha
onready var lifespan = $Lifespan
onready var hitbox = $Hitbox
onready var hitboxCol = $Hitbox/CollisionShape2D
onready var bulletCol = $CollisionShape2D
onready var sprite = $Sprite

func _ready():
	hide()
	yield(get_tree().create_timer(cast_time),"timeout")
	show()
	if is_player:
		MusicSystem.set_sfx2d(MusicSystem.effect.WATERSHOT,self,true)
	else:
		MusicSystem.set_sfx2d(MusicSystem.effect.SHOT,self,true)
	var vector = Vector2(DataImport.bullet_data[bullet].projectile_scalex,DataImport.bullet_data[bullet].projectile_scaley)
	
	knockback = DataImport.bullet_data[bullet].knockback
	attack += DataImport.bullet_data[bullet].bonus_attack
	multiplier = DataImport.bullet_data[bullet].mutiple_attack
	speed = DataImport.bullet_data[bullet].projectile_speed+addSpeed
#	hitboxCol.shape.radius = DataImport.bullet_data[bullet].collision
	var new_hitbox = CircleShape2D.new()
	new_hitbox.set_radius(DataImport.bullet_data[bullet].collision)
	hitboxCol.call_deferred("set","shape",new_hitbox)
#	bulletCol.shape.radius = DataImport.bullet_data[bullet].collision
	var new_bullet = CircleShape2D.new()
	new_bullet.set_radius(DataImport.bullet_data[bullet].collision)
	bulletCol.call_deferred("set","shape",new_bullet)
	sprite.position+=Vector2(DataImport.bullet_data[bullet].sprite_x,DataImport.bullet_data[bullet].sprite_y)
	sprite.set_scale(vector)
	lifespan.start(DataImport.bullet_data[bullet].lifetime)
	hitbox.position = Vector2(DataImport.bullet_data[bullet].position_x,DataImport.bullet_data[bullet].position_y)
	bulletCol.position = Vector2(DataImport.bullet_data[bullet].position_x,DataImport.bullet_data[bullet].position_y)
	sprite.animation = DataImport.bullet_data[bullet].sprite_name
	if cast_time <= 0:
		conf_bullet()
	else:
		$CastTime.start(cast_time)
	
#func _process(delta):
#	velocity = move_and_slide(Vector2(speed,0).rotated(rotation))
#	if get_slide_count() > 0:
#		bullet_splash()

func bullet_splash(collision=true):
	if !splash:
		if is_aoe:
			splasha = load("res://assets/scene/Effect/AOESplash.tscn")
		else:
			splasha = load("res://assets/scene/Effect/BulletSplash.tscn")
		var splashi=Global.instance_node(splasha,get_global_position())
		splashi.z_index = 3
		if is_aoe:
			splashi.splash_anim = DataImport.bullet_data[bullet].splash
			splashi.attack = attack
			splashi.multiplier = multiplier
			splashi.knockback = knockback
			splashi.knockback_vector = knockback_vector
			splashi.is_player =is_player
			splashi.set_scale( Vector2(DataImport.bullet_data[bullet].projectile_scalex,DataImport.bullet_data[bullet].projectile_scaley))
			splashi.starttime = DataImport.bullet_data[bullet].start_delay_damage
			splashi.finishtime = DataImport.bullet_data[bullet].finish_delay_damage
			splashi.radius = DataImport.bullet_data[bullet].aoe
		else:
			splashi.bullet = bullet
			splashi.is_player = is_player
		Global.spawn_node(splashi,get_tree().get_root())
	if (!collision):
		queue_free()
	else:
		splash=true
		self.hide()
		hitbox.set_collision_layer_bit(6,0)
		hitbox.set_collision_layer_bit(7,0)
		hitbox.set_collision_mask_bit(0,0)
		hitbox.set_collision_mask_bit(2,0)
		hitbox.set_collision_mask_bit(3,0)
		hitbox.set_collision_mask_bit(5,0)


func conf_bullet():
	if is_player:
		hitbox.set_collision_layer_bit(6,1)
		hitbox.set_collision_mask_bit(0,1)
		hitbox.set_collision_mask_bit(3,1)
		hitbox.set_collision_mask_bit(5,1)
	else:
		hitbox.set_collision_layer_bit(7,1)
		hitbox.set_collision_mask_bit(0,1)
		hitbox.set_collision_mask_bit(2,1)
		hitbox.set_collision_mask_bit(5,1)
	apply_impulse(velocity,Vector2(speed,0).rotated(rotation))

func _on_Hitbox_area_entered(_area):
	bullet_splash()
	print('hitted')
	
func _on_Lifespan_timeout():
	bullet_splash(false)

func _on_Bullet_body_entered(_body):
	bullet_splash()
	pass # Replace with function body.


func _on_CastTime_timeout():
	conf_bullet()
	pass # Replace with function body.
