extends Node2D

onready var sprite = $AnimatedSprite
var anim = "worm"

var flip = false
onready var timer = $DeathLife

func _ready():
	add_to_group("Boneflesh")
	sprite.frame = 0
	sprite.flip_h = flip
	sprite.animation = anim+"_death"

	
func _on_AnimatedSprite_animation_finished():
	if DataImport.enemy_data[anim].decoy_time > 0 :
		timer.start(DataImport.enemy_data[anim].decoy_time)
	else :
		queue_free()

func _on_DeathLife_timeout():
	queue_free()

func delete_all_flesh():
	var delete=get_tree().get_nodes_in_group("Boneflesh")
	for value in delete:
		value.remove_from_group("Boneflesh")
		value.queue_free()
	
