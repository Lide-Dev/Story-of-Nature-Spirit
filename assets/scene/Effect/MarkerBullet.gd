extends Position2D

var start

func _ready():
	$AnimationPlayer.play("mark")
	$Timer.start(start)

func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
