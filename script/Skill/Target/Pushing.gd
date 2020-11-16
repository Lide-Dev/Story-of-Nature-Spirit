extends Node2D

enum type_push{
	LINEAR,
	TARGETED,
	RANDOM
}

export (type_push) var type
export (String) var name_skill
export (bool) var is_damaging
export (float) var damage
export (float) var value_linear = 0
export (float) var value_random = 0
export (float) var knockback =0
export (float) var cast_time = 0
export (bool) var is_player = false
export (float) var speed = 0
#export (float) var skill_duration = 2
var line

var path: PoolVector2Array
var cast_timer
var target
var caster
var target_real
var duration_timer
var skill_on = false
var velocity = Vector2.ZERO
var duration_time = 4

func _ready():
	init_config()

func init_config():
	if cast_time > 0:
		cast_timer = Timer.new()
		add_child(cast_timer)
		cast_timer.wait_time = cast_time
		cast_timer.one_shot = true
		cast_timer.connect("timeout",self,"on_cast_finished")
		
		duration_timer = Timer.new()
		duration_timer.wait_time = 4
		duration_timer.one_shot = true
		duration_timer.connect("timeout",self,"on_duration_finished")
		add_child(duration_timer)
		if is_player:
			$Area2D.set_collision_layer_bit(6,true)
			$Area2D.set_collision_mask_bit(3,true)
		else:
			$Area2D.set_collision_layer_bit(7,true)
			$Area2D.set_collision_mask_bit(2,true)

func cast_spell(cster,trget):
	if cast_time > 0:
		caster=cster
		target=trget
		target_real = target.global_position
		duration_timer.start(duration_time)
		cast_timer.start(cast_time)
		line = Line2D.new()
		var rot = (target_real-caster.global_position).angle()
#		print(str(rot)+" Rotate and "+ str(rad2deg(rot))+" Degrees")
#		caster.look_at(target_real)
		target_real = (Vector2(value_linear,0).rotated(rot))+caster.global_position
		line.width=$Area2D/CollisionShape2D.shape.radius*2
		line.modulate = Color(1,0,0,0.5)
		path.push_back(caster.global_position)
		path.push_back(target_real)
		Global.spawn_node(line,get_tree().get_root())
		line.points = path
	else:
		skill_push()

func skill_push():
	skill_on = true

func _physics_process(delta):
	if skill_on:
		var direction=caster.global_position.direction_to(target_real)
		caster.velocity = caster.velocity.move_toward(direction*500, 500 *delta)
#		print (caster.global_position.distance_to(target_real))
		caster.sprite.flip_h =  caster.velocity.x < 0
		if caster.global_position.distance_to(target_real)<= 50:
			skill_finish()
			print("END")

func on_cast_finished():
	skill_push()
	path = []
	line.points= []
	line.queue_free()
#	$Area2D.set_deferred("monitorable",true)
	$Area2D.set_deferred("monitoring",true)

func _on_Area2D_area_entered(area):
	print("DAMAGED")
	var tgt
	if is_player:
		tgt = area.get_owner()
	else:
		tgt = area.get_parent()
	var tgtstat= target.stats
	var calc = (damage-(tgtstat.defense*2))
	if (calc<=0):
		calc = 0
	tgtstat.hp -= int(calc)
	if !is_player:
		var eknockback_vector=(target.global_position - caster.global_position).normalized()
		target.eknockback = eknockback_vector*knockback
	Global.create_txt_damage(tgt.global_position,calc,tgtstat.maxhp)
	

func on_duration_finished():
	skill_finish()

func skill_finish():
#	$Area2D.set_deferred("monitorable",false)
	$Area2D.set_deferred("monitoring",false)
	skill_on = false
	print("Spell Push Complete")
	caster.state = caster.IDLE
	caster.velocity = Vector2.ZERO
	caster.sprite.animation = "move"
	duration_timer.stop()
