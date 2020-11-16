extends Node2D

var is_playing = false
var is_fadein = false
var is_fadeout = false
var is_free = false
var is_loop = false
var is_expire = false
var target

var res_sfx = ""
onready var sfxplay = $SFXPlayer

func _ready():
	add_to_group("sfx2d")
	sfxplay.stream = res_sfx
	sfxplay.volume_db = 0
	play_sfx(0)

func play_sfx(delay):
	if delay > 0:
		yield(get_tree().create_timer(delay),"timeout")
	is_playing = true
	sfxplay.play()

func _on_SFXPlayer_finished():
	if is_expire:
#		print(str(self)+" sfx on "+str(target)+" has finish!")
		self.queue_free()
