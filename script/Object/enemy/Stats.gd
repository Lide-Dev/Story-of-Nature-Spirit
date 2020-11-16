extends Node

signal no_health

export (float) var MaxHP = 0 setget set_mhp
export (float) var MaxPP = 0 setget set_mpp
export (float) var Attack = 2 setget set_att
export (float) var Defense = 0 setget set_def
export (float) var Speed = 100 setget set_spd
onready var RatioSpeedDec = 1.5 #pengurangan speed di setiap air diambil 
onready var HP = MaxHP setget set_hp
onready var PP = MaxPP setget set_pp #Powder Point
onready var WP = 0  setget set_wp #Water Point

func _ready():
	pass

func set_hp(hp):
	HP = hp
	if (HP <= 0):
		emit_signal("no_health")

func set_pp(pp):
	PP = pp

func set_wp(wp):
	WP = wp

func set_mhp(mhp):
	MaxHP= mhp

func set_mpp(mpp):
	MaxPP= mpp

func set_att(att):
	Attack= att

func set_def(def):
	Defense= def

func set_spd(spd):
	Speed= spd




