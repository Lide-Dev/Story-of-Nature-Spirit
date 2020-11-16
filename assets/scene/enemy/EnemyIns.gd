extends Node2D

onready var hurtbox = $Hurtbox
onready var hitbox = $Hitbox
onready var enemyd = $EnemyDetection
var path_nav
var enemy_parent

func _ready():
	set_owner(get_node("../"))
	hurtbox.set_owner(get_node("../"))
	hitbox.set_owner(get_node("../"))
	enemyd.set_owner(get_node("../"))
	path_nav=get_node("../").path_nav
	$Sprite.frame=0                                        

func set_maxhp_bar(value,maxval):
	$HPBar/HP.max_value = maxval
	$HPBar/HP.value=value
