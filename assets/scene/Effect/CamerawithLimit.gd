extends Camera2D

onready var topleft = $Limit/TopLeft
onready var bottomright = $Limit/BottomRight

func _ready():
	add_to_group("camera")
	reset_conf()

func set_topleft(value):
#	print(value)
	topleft.position = value
	reset_conf()
	
func set_bottomright(value):
#	print(value)
	bottomright.position = value
#	print(bottomright.position)
	reset_conf()

func reset_conf():
	limit_top = topleft.position.y
	limit_left = topleft.position.x
	limit_bottom = bottomright.position.y
	limit_right = bottomright.position.x
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
