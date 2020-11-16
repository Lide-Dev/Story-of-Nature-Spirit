extends Control

onready var ppbar = $PointBar/VBoxContainer/PPBar
onready var hpbar = $PointBar/VBoxContainer/HPBar
onready var wpbar = $PointBar/WPBar
onready var wppercent= $PointBar/VBoxContainer/HBoxContainer/WP
onready var anim = $PictureProfile/AnimatedSprite
var stats

func _ready():
	add_to_group("statusbar_gui")

func update_bar(key,value,maxval,minval=0):
	if key=="hp":
		hpbar.max_value = maxval
		hpbar.min_value = minval
		hpbar.value = value
		if value/maxval <= 0:
			anim.play("0")
		elif value/maxval <= 0.25:
			anim.play("25")
		elif value/maxval <= 0.50:
			anim.play("50")
		elif value/maxval <= 0.75:
			anim.play("75")
		elif value/maxval <= 1:
			anim.play("100")
	elif key=="pp":
		ppbar.max_value = maxval
		ppbar.min_value = minval
		ppbar.value = value
	elif key=="wp":
		wpbar.max_value = maxval
		wpbar.min_value = minval
		wpbar.value = value
		wppercent.text = str(int(value/maxval*100))+"%"
