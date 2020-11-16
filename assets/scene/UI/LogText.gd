extends Label

var timer

func _ready():
	yield(get_tree().create_timer(timer),"timeout")
	queue_free()

