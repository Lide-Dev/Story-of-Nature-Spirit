extends Area2D

var arr_obj
var questsystem

func _ready():
	get_tree().call_group("mark_system","node_added",self,"quest")
	position = Vector2(float(arr_obj["position"][0]),float(arr_obj["position"][1]))
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(float(arr_obj["area"][0]),float(arr_obj["area"][1])))
	$CollisionShape2D.shape = shape

func _on_Travel_body_entered(_body):
	yield(get_tree().create_timer(0.3),"timeout")
	questsystem.set_objcomplete(arr_obj)
	queue_free()
