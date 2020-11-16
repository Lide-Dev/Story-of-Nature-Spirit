extends Area2D

var player = null
var orihate

onready var area = $CollisionShape2D

func _ready():
	orihate = CircleShape2D.new()
	orihate.set_radius(area.shape.radius)

func can_see_player():
	return player != null

func _on_Area2D_body_entered(body):
	player = body

func _on_EnemyDetection_body_exited(_body):
	player = null

func _on_Hate_timeout():
	$CollisionShape2D.shape = orihate
