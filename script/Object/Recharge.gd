extends Area2D

enum tier{
	HIGH,
	MEDIUM,
	LOW
}

export (float) var maxpp = 10
export (tier) var regeneration = tier.LOW
export (tier) var share_ratio = tier.LOW
var pp:float
var regen:float
var ratio:float
var player_interact
var player
var world

func _ready():
	world=get_tree().get_root().get_node("Game/World")
	pp = maxpp
	$ProgressBar.max_value = maxpp
	$ProgressBar.value = pp
	match regeneration:
		tier.HIGH:
			regen = maxpp*0.002
		tier.MEDIUM:
			regen = maxpp*0.001
		tier.LOW:
			regen = maxpp*0.0005
	match share_ratio:
		tier.HIGH:
			ratio = maxpp*0.10
		tier.MEDIUM:
			ratio = maxpp*0.05
		tier.LOW:
			ratio = maxpp*0.025

func _on_Timer_timeout():
	if player_interact:
		if pp > 0:
			if world.stats.pp < world.stats.maxpp:
				world.stats.pp += ratio
				pp -= ratio
	if pp <= maxpp:
		pp += regen
	else:
		pp = maxpp
	$ProgressBar.value = pp
	pass # Replace with function body.

func _on_Recharge_body_entered(body):
#	print("RECHARGE")
	player_interact = true
	player = body
	pass # Replace with function body.

func _on_Recharge_body_exited(body):
#	print("DISRECHARGE")
	player_interact = false
	player = body
	pass # Replace with function body.
