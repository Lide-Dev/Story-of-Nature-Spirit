extends Node2D

var splash_anim = "SmellCloud"
var multiplier = 0
var attack = 0
var knockback = 0
var knockback_vector = Vector2.ZERO
var splash= false
var is_player = true
var valid_dps = false
var starttime = 0
var finishtime = 0
var radius = 0

onready var startdelay=$StartDelayDamage
onready var lifespan = $Lifespan
onready var hitbox = $Hitbox
onready var dps = $DPS

func _ready():
	var new_circle = CircleShape2D.new()
	new_circle.set_radius(radius)
	$Hitbox/CollisionShape2D.shape = new_circle
	hitbox.set_deferred("monitorable",false)
	lifespan.start(finishtime)
	startdelay.start(starttime)
	MusicSystem.set_sfx2d(MusicSystem.effect.WATERSPLASHLOOP,self,false)

func _on_Hitbox_area_entered(_area):
	if valid_dps :
		valid_dps = false
		hitbox.set_deferred("monitorable",false)
		dps.start(1)

func _on_StartDelayDamage_timeout():
	valid_dps = true
	hitbox.set_deferred("monitorable",true)
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
	pass # Replace with function body.


func _on_DPS_timeout():
	hitbox.set_deferred("monitorable",true)
	valid_dps = true
	pass # Replace with function body.

func _on_Lifespan_timeout():
	queue_free()
	pass # Replace with function body.
