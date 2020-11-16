extends CenterContainer

export (String) var name_monster
export (String) var level
export (bool) var is_parasite

onready var stats = get_node("../../Stats")
onready var green_bar = preload("res://assets/img/UI/green_bar.png")
onready var yellow_bar = preload("res://assets/img/UI/yellow_bar.png")
onready var red_bar = preload("res://assets/img/UI/red_bar.png")
onready var hpbar = $HP
onready var label = $Label


func _ready():
	label.text = name_monster+" Lv."+level
	hpbar.max_value = stats.maxhp
	stats.connect("hp_changed",self,"_on_Stats_hp_changed")

func _on_Stats_hp_changed(hp):
	hpbar.value = hp
	var percentage_value = hp/hpbar.max_value
	if percentage_value <= 0.25:
		hpbar.texture_progress = red_bar
	elif percentage_value <= 0.50:
		hpbar.texture_progress = yellow_bar
		
