extends Node

signal fadein_finished
signal fadeout_finished

var is_playing = false
var is_fadein = false
var is_fadeout = false
var is_free = false
var res_bgm = ""
onready var bgmplayer = $BGMPlayer
onready var tween = $Tween

func _ready():
	add_to_group("bgm")
	bgmplayer.stream = res_bgm
	bgmplayer.volume_db = -80
	is_playing = true
	is_fadein = true
	

func _process(_delta):
	if is_fadein:
		bgmplayer.playing=true
#		print(bgmplayer.volume_db)
		bgmplayer.volume_db +=2
		if bgmplayer.volume_db >= 0:
			is_fadein=false
			emit_signal("fadein_finished")
	if is_fadeout:
		bgmplayer.volume_db -=2
		if bgmplayer.volume_db <= -75:
			bgmplayer.playing=false
			is_fadeout=false
			emit_signal("fadeout_finished")
#		print(bgmplayer.volume_db)

func bgm_pause(value:bool):
	if value:
		is_fadeout=true
		is_fadein=false
	else:
		is_fadein=true
		is_fadeout=false

func bgm_finish():
	is_free=true
	is_fadeout=true

func _on_BGM_fadeout_finished():
	if is_free:
		queue_free()

