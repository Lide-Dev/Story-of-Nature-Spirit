extends Position2D

var damage = 0
var hp = 0
var speed = 40
#var is_fatal = false
onready var txt = $Text

func _ready():
	txt.text = str(damage)
	if typeof(damage) != TYPE_STRING:
		var percent = damage/hp*100
		if percent > 40:
#			is_fatal = true
			speed = 80
			$Timer.start(0.5)
			set("custom_fonts/font","res://assets/fonts/textdamage.tres")
			txt.modulate = Color("800000")
		else:
			$Timer.start(1)
	else:
		speed = 40
		$Timer.start(1)
		set("custom_fonts/font","res://assets/fonts/textpopup.tres")
		txt.modulate = Color.white
#	tween.interpolate_property(self,"position",Vector2(0,0),Vector2(0,100),0.5,Tween.TRANS_LINEAR,2,0,5)
	
func _process(delta):
	position += Vector2(0,-1)*speed *delta
	scale += Vector2(0.01,0.01)
	
	

func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
