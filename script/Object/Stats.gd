extends Node

signal no_health
signal hp_changed(hp)
signal mhp_changed(mhp)
signal pp_changed(pp)
signal mpp_changed(mpp)
signal wp_changed(wp)

export (bool) var is_player = false
export (int) var soil = 1 setget set_soil
export (int) var slippery = 1 setget set_slip
export (int) var fertility = 1 setget set_fert
export (float) var maxhp = 1
export (float) var maxpp = 1
export (float) var attack = 1
export (float) var defense = 1 
export (float) var max_speed = 100 
export (float) var speed = 100 
export (float) var attack_speed = 1 
export (int) var knockback = 100
export (int) var knockback_acc = 200
export (int) var luck = 0
onready var ratiospeeddec = 2.5 #pengurangan speed di setiap air diambil 
onready var ratiowaterdec = 0.025
export (float) var delay_attack = 1
onready var hp:float = maxhp setget set_hp
onready var pp:float = maxpp setget set_pp #Powder Point
onready var wp:float = 0  setget set_wp #Water Point
var mainstat = {}
var initstat = {}
var optionalstat = {}
var equipstat = {"head":{},"orb1":{},"orb2":{},"ring":{}}
var skilltree = {}
var totalskillstat = {}
var totalequipstat = {}
var status_gui
var quest

func _ready():
	if is_player:
		optionalstat = {"delay_attack":delay_attack,"ratiowaterdec":ratiowaterdec}
		initstat = {"maxhp":maxhp,"defense": defense,"maxpp":maxpp,"attack":attack,"ratiospeeddec": ratiospeeddec,"speed":speed,"attack_speed":attack_speed,"luck":luck}
		mainstat = {"maxhp":soil*3,"defense": soil*0.25,"maxpp":fertility*2,"attack":fertility*0.5,"ratiospeeddec": slippery*0.01,"speed":slippery*2.5}
		totalequipstat = {"maxhp":0,"defense":0,"maxpp":0,"attack":0,"ratiospeeddec":0,"speed":0,"soil":0,"slippery":0,"fertility":0}
		update_stat()
		hp= maxhp
		pp= maxpp
	
func load_game(value):
	var keys = value.keys()
	for key in keys:
		set(key,value[key])
	update_stat()

func set_hp(xhp):
	if xhp<=maxhp:
		hp = xhp
	else:
		hp = maxhp
	emit_signal("hp_changed",hp)
	if is_player:
		var group=get_tree().get_nodes_in_group("statusbar_gui")
		status_gui=group[0]
		status_gui.update_bar("hp",hp,maxhp)
		quest.update_stat("hp",hp)
	if (hp <= 0):
		emit_signal("no_health")
	

func set_pp(xpp):
	if xpp<=maxpp:
		pp = xpp
	else:
		pp = maxpp
	if is_player:
		var group=get_tree().get_nodes_in_group("statusbar_gui")
		status_gui=group[0]
		status_gui.update_bar("pp",pp,maxpp)
		quest.update_stat("pp",pp)
	emit_signal("pp_changed",pp)
	

func set_wp(xwp):
	if wp>=0:
		wp = xwp
	else:
		wp = 0
	if is_player:
		var group=get_tree().get_nodes_in_group("statusbar_gui")
		status_gui=group[0]
		status_gui.update_bar("wp",wp,maxhp)
		quest.update_stat("wp",(wp/maxhp)*100)
	emit_signal("wp_changed",wp)
	update_stat()

func set_soil(xsoil):
	soil = xsoil

func set_slip(slip):
	slippery = slip

func set_fert(fert):
	fertility= fert

func percentage(key,value):
	return get(key)*value

func total_skillstat():
	var skillkeys = ["Concentration","SolidSoil","MagicalEnergy","LightLoad","Moist"]
	totalskillstat = {"firerate":0,"maxhp":0,"bonusequip":0,"ratiospeeddec":0,"ratiowaterdec":0}
	var keys = totalskillstat.keys()
	var i = 0
	if skilltree.has("Concentration"):
		for key in keys:
			print(key)
			totalskillstat[key] = DataImport.skill_data[skillkeys[i]].value * skilltree[skillkeys[i]].lvl
			i+=1
			print(totalskillstat[key])

func total_equipstat():
	totalequipstat = {"maxhp":0,"defense":0,"maxpp":0,"attack":0,"ratiospeeddec":0,"speed":0,"soil":0,"slippery":0,"fertility":0}
	for eq in equipstat:
		var key=equipstat[eq].keys()
		var i = 0
		if key.size()>0:
			for stt in key:
				if str(equipstat[eq][stt]).is_valid_integer():
					if (eq == "orb1" && eq =="orb2"):
						totalequipstat[stt]+=equipstat[eq][stt]+(equipstat[eq][stt]*totalskillstat.bonusequip)
					else:
						totalequipstat[stt]+=equipstat[eq][stt]
				else:
					if (eq == "orb1" && eq =="orb2"):
						var p = percentage(stt,equipstat[eq][stt])
						totalequipstat[key[i]]+= p + (p*totalskillstat.bonusequip)
					else:
						totalequipstat[key[i]]+=percentage(stt,equipstat[eq][stt])
				i+=1
				print("Total "+str(stt)+": "+str(totalequipstat[stt]))

func update_stat():
	if is_player:
		total_skillstat()
		total_equipstat()
		mainstat = {
			"maxhp":(soil+totalequipstat["soil"])*3,
			"defense":(soil+totalequipstat["soil"])*0.25,
			"maxpp":(fertility+totalequipstat["fertility"])*2,
			"attack":(fertility+totalequipstat["fertility"])*0.5,
			"ratiospeeddec":(slippery+totalequipstat["slippery"])*0.01,
			"speed":(slippery+totalequipstat["slippery"])*2.5
		}
#		var keys=mainstat.keys()
#		for key in keys:
#			print("Total main "+str(key)+": "+str(totalequipstat[key]))
		
		delay_attack = optionalstat["delay_attack"] + totalskillstat.firerate
		ratiowaterdec = optionalstat["ratiowaterdec"] + totalskillstat.ratiowaterdec
		ratiospeeddec = initstat["ratiospeeddec"]-mainstat["ratiospeeddec"]+totalequipstat["ratiospeeddec"]
		var m = initstat["maxhp"]+mainstat["maxhp"]+totalequipstat["maxhp"]
		maxhp = m+(m*totalskillstat.maxhp)
		maxpp = initstat["maxpp"]+mainstat["maxpp"]+totalequipstat["maxpp"]
		attack = initstat["attack"]+mainstat["attack"]+totalequipstat["attack"]
		defense = initstat["defense"]+mainstat["defense"]++totalequipstat["defense"]
		speed = initstat["speed"]+mainstat["speed"]+totalequipstat["speed"]-(wp*ratiospeeddec)
		
		var group=get_tree().get_nodes_in_group("statusbar_gui")
		status_gui=group[0]
		status_gui.update_bar("hp",hp,maxhp)
		status_gui.update_bar("pp",pp,maxpp)
		status_gui.update_bar("wp",wp,maxhp)

func revive():
	set_hp(maxhp)
	set_pp(maxpp)
	set_wp(0)
