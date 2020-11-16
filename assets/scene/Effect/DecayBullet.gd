extends RigidBody2D

var bullet = "SmellCloud"
var cast_time = 0
var multiplier = 0
var addSpeed = 0
var attack = 0
var knockback = 0
var speed = 200
var velocity = Vector2.ZERO
var knockback_vector = Vector2.ZERO
var splash= false
var is_player = true
var valid_dps = true
onready var lifespan = $Lifespan
onready var hitbox = $Hitbox
onready var hitboxCol = $Hitbox/CollisionShape2D
onready var bulletCol = $CollisionShape2D
onready var sprite = $Sprite
onready var dps = $DPS

func _ready():
	var vector = Vector2(DataImport.bullet_data[bullet].projectile_scalex,DataImport.bullet_data[bullet].projectile_scaley)
	
	knockback = DataImport.bullet_data[bullet].knockback
	attack += DataImport.bullet_data[bullet].bonus_attack
	multiplier = DataImport.bullet_data[bullet].mutiple_attack
	speed = DataImport.bullet_data[bullet].projectile_speed+addSpeed
	match DataImport.bullet_data[bullet].type_collision:
		"circle":
			var new_hitbox = CircleShape2D.new()
			new_hitbox.set_radius(DataImport.bullet_data[bullet].collision)
			hitboxCol.call_deferred("set","shape",new_hitbox)
			var new_bullet = CircleShape2D.new()
			new_bullet.set_radius(DataImport.bullet_data[bullet].collision)
			bulletCol.call_deferred("set","shape",new_bullet)
		"capsule":
			var new_hitbox = CapsuleShape2D.new()
			var new_bullet = CapsuleShape2D.new()
			var split = DataImport.bullet_data[bullet].collision.split(",",true,0)
			new_hitbox.set_radius(int(split[0]))
			new_hitbox.set_height(int(split[1]))
			hitbox.rotation_degrees = int(split[2])
			new_bullet.set_radius(int(split[0]))
			new_bullet.set_height(int(split[1]))
			bulletCol.rotation_degrees=int(split[2])
			hitboxCol.call_deferred("set","shape",new_hitbox)
			bulletCol.call_deferred("set","shape",new_bullet)
	sprite.set_scale(vector)
	lifespan.start(DataImport.bullet_data[bullet].lifetime)
	hitbox.position = Vector2(DataImport.bullet_data[bullet].position_x,DataImport.bullet_data[bullet].position_y)
	bulletCol.position = Vector2(DataImport.bullet_data[bullet].position_x,DataImport.bullet_data[bullet].position_y)
	sprite.position+=Vector2(DataImport.bullet_data[bullet].sprite_x,DataImport.bullet_data[bullet].sprite_y)
	sprite.animation = DataImport.bullet_data[bullet].sprite_name
	$CastTime.start(cast_time)
	
#func _process(delta):
#	velocity = move_and_slide(Vector2(speed,0).rotated(rotation))
#	if get_slide_count() > 0:
#		bullet_splash()

func bullet_splash():
	queue_free()

func _on_Hitbox_area_entered(_area):
	if valid_dps :
		valid_dps = false
		hitbox.set_deferred("monitorable",false)
		dps.start(1)
	
func _on_Lifespan_timeout():
	bullet_splash()

func _on_Bullet_body_entered(_body):
	bullet_splash()

func _on_DPS_timeout():
	hitbox.set_deferred("monitorable",true)
	valid_dps = true
	pass # Replace with function body.

func _on_CastTime_timeout():
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
	set_applied_force(Vector2(-speed/4,0).rotated(rotation))
