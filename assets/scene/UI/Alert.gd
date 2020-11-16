extends Control

onready var alert = $CenterContainer/PanelContainer/AlertValue
onready var timer = $Timer
onready var effect = $Tween
var tween_active = false

func set_alert(text,time=5):
	if tween_active:
		effect.remove_all()
	tween_active=true
	alert.text=text
	timer.start(time)
	show()
	effect.interpolate_property(self,"modulate",Color(0,0,0,0),Color(1,1,1,1),0.3,Tween.TRANS_QUAD,Tween.EASE_IN)
	effect.interpolate_property(self,"modulate",Color(1,1,1,1),Color(0,0,0,0),0.3,Tween.TRANS_QUAD,Tween.EASE_OUT,time-0.6)
	effect.start()

func alert_spawning():
	hide()

func _on_Timer_timeout():
	remove_from_group("Alert")
	hide()
	tween_active=false
	queue_free()
	pass # Replace with function body.
