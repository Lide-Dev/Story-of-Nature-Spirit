extends TextureProgress

onready var stats = get_node("../../Stats")
onready var green_bar = preload("res://assets/img/UI/green_bar.png")
onready var yellow_bar = preload("res://assets/img/UI/yellow_bar.png")
onready var red_bar = preload("res://assets/img/UI/red_bar.png")

func _ready():
	max_value = stats.maxhp
	stats.connect("hp_changed",self,"_on_Stats_hp_changed")
	stats.connect("mhp_changed",self,"_on_Stats_mhp_changed")

func _on_Stats_hp_changed(hp):
	value = hp
	var percentage_value = value/max_value
	if percentage_value <= 0.25:
		texture_progress = red_bar
	elif percentage_value <= 0.50:
		texture_progress = yellow_bar
		
func _on_Stats_mhp_changed(mhp):
	max_value = mhp
