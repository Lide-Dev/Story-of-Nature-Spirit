extends Node2D

######
# JANGAN LUPA GANTI PATH !
######
######
# JANGAN LUPA GANTI PATH !
######
######
# JANGAN LUPA GANTI PATH !
######

func _ready():
	$Camera2D.current = true
	yield(get_tree().create_timer(1),"timeout")
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png("res://assets/scene/Maps/gripoli_fall/gripoli_tyrant/minimap.png")

######
# JANGAN LUPA GANTI PATH !
######
######
# JANGAN LUPA GANTI PATH !
######
######
