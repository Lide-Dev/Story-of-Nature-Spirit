extends Node2D

onready var sprite = $AnimatedSprite
var anim = "player"
var flip = false
onready var timer = $DeathLife

func _ready():
	sprite.frame = 0
	if anim != "player":
		sprite.flip_h = flip
	sprite.animation = anim+"_death"

func _on_AnimatedSprite_animation_finished():
	if anim != "player":
		queue_free()

func _on_DeathLife_timeout():
	queue_free()
