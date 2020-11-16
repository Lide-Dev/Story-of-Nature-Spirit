extends Control

onready var npcinteract = $Hbox/Interact
onready var regen = $Hbox/Regen
onready var regenvalue = $Hbox/Regen/Value
var percent = 0
#var stats

func _ready():
	add_to_group("InteractInfo")
#	stats=get_parent().stat

func show_interactinfo(value):
	if value:
		npcinteract.show()
	else:
		npcinteract.hide()

func _process(_delta):
#	if percent >= 100:
#		regenvalue.add_color_override("font_color",Color.red)
#	elif percent >= 80:
#		regenvalue.add_color_override("font_color",Color.white)
#		anim_regen()
#	else:
#		regenvalue.add_color_override("font_color",Color.white)
#		$Tween.remove(regen)
#		$Tween.reset_all()
	pass

func show_regeninfo(value):
	if value:
		regen.show()
		if percent >= 100:
			regenvalue.add_color_override("font_color",Color.red)
		elif percent >= 80:
			regenvalue.add_color_override("font_color",Color.white)
			anim_regen()
		else:
			regenvalue.add_color_override("font_color",Color.white)
			$Tween.remove(regen)
			$Tween.reset_all()
	else:
		$Tween.reset_all()
		$Tween.remove(regen)
		regen.hide()

func set_percent(value):
	percent = value
	if percent >= 100:
		regenvalue.add_color_override("font_color",Color.red)
	elif percent >= 80:
		anim_regen()
		regenvalue.add_color_override("font_color",Color.white)
	else:
		regenvalue.add_color_override("font_color",Color.white)
		$Tween.reset_all()
		$Tween.remove(regen)
		

func process_regen(value):
	print("PROCESSREGEN")
	if value:
		if percent >=100:
			regenvalue.text="Don't exaggerate!"
		else:
			regenvalue.text="Stop Taking Water"
	else:
		if percent >=100:
			regenvalue.text="Don't exaggerate!"
		else:
			regenvalue.text="Take Water"

func anim_regen():
	if !$Tween.is_active():
		$Tween.interpolate_property(regen,"rect_scale",Vector2(1,1),Vector2(1.5,1.5),0.5,Tween.TRANS_QUAD,Tween.EASE_IN)
		$Tween.interpolate_property(regen,"rect_scale",Vector2(1.5,1.5),Vector2(1,1),0.5,Tween.TRANS_QUAD,Tween.EASE_IN,0.5)
		$Tween.repeat = true
		$Tween.start()
