extends Control

signal opening_complete
var alpha = 0
var titik = ""
var loadcomplete = false

func set_time(time):
	randomize()
	
	$AnimatedSprite.play(str(randi()%6 +1))
	$AnimatedSprite.frame = 0
	yield(get_tree().create_timer(time),"timeout")
	emit_signal("opening_complete")
	loadcomplete = true

func loading_start():
	randomize()
	$AnimatedSprite.play(str(randi()%6 +1))
	$AnimatedSprite.frame = 0
	loadcomplete = false
#	get_tree().paused = true

func loading_finish(get=false,time=1):
	yield(get_tree().create_timer(time),"timeout")
	loadcomplete = true
#	get_tree().paused = false

func _process(_delta):
	if !loadcomplete:
		if alpha <= 1:
			$TextureRect.color=Color(0,0,0,alpha)
			alpha += 0.1
	else:
		if alpha > 0:
			$TextureRect.color=Color(0,0,0,alpha)
			modulate =Color(0,0,0,alpha)
			alpha -= 0.1
		else:
			queue_free()

func _on_titik_timeout():
	if titik != "....":
		titik += "."
		$Label.text = "Loading"+titik
	else:
		titik = ""
	
