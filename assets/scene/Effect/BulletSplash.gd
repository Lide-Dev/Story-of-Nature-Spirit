extends Node2D

onready var sprite = $AnimatedSprite
var bullet = "WaterShot"
var is_player

func _ready():
	sprite.frame = 0
	if bullet != "MeleeEffect":
		if is_player:
			MusicSystem.set_sfx2d(MusicSystem.effect.WATERSPLASH,self)
		sprite.play(DataImport.bullet_data[bullet].splash)
		var vector = Vector2(DataImport.bullet_data[bullet].projectile_scalex,DataImport.bullet_data[bullet].projectile_scaley)
		sprite.set_scale(vector)
	else:
		sprite.play("MeleeEffect")

func _on_AnimatedSprite_animation_finished():
	queue_free()
