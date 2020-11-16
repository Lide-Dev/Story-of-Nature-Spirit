extends CenterContainer

var worldnode
var stats
var xp
var next_xp
var previous_xp
var tooltip
var poin=0
var poinuse = 0 
var soil=0
var slippery=0
var fertility=0
var soiluse=0
var slipperyuse=0
var fertilityuse=0
var statsrep= {}
onready var pollen_tag = $StatusBox/StatusXP/VBoxContainer/HBoxContainer2/PollenValue
onready var fol_tag = $StatusBox/StatusXP/VBoxContainer/HBoxContainer3/FoLValue
onready var bar_xp = $StatusBox/StatusXP/VBoxContainer/ProgressBar
onready var level = $StatusBox/StatusXP/VBoxContainer/HBoxContainer/LevelTag
onready var maxhp_tag = $StatusBox/StatusInfo1/VBoxContainer/MaxHPContainer/Value
onready var maxpp_tag = $StatusBox/StatusInfo1/VBoxContainer/MaxPPContainer/Value
onready var attack_tag = $StatusBox/StatusInfo1/VBoxContainer/AttackContainer/Value
onready var defense_tag = $StatusBox/StatusInfo1/VBoxContainer/DefenseContainer/Value
onready var speed_tag = $StatusBox/StatusInfo2/VBoxContainer2/SpeedContainer/Value
onready var aspeed_tag = $StatusBox/StatusInfo2/VBoxContainer2/ASpeedContainer/Value
onready var rs_tag = $StatusBox/StatusInfo2/VBoxContainer2/RatioSpeedContainer/Value
onready var rw_tag = $StatusBox/StatusInfo2/VBoxContainer2/LuckContainer/Value
onready var point_tag = $StatusBox/StatusPoint/VBoxContainer/CenterContainer/HBoxContainer2/PointsValue
onready var soil_tag= $StatusBox/StatusPoint/VBoxContainer/StatsSoil/HBoxContainer/SoilValue
onready var slippery_tag= $StatusBox/StatusPoint/VBoxContainer/StatsSlippery/HBoxContainer2/SlipperyValue
onready var fertility_tag= $StatusBox/StatusPoint/VBoxContainer/StatsFertility/HBoxContainer2/FertilityValue
onready var add_button = $StatusBox/StatusPoint/VBoxContainer/CenterContainer/HBoxContainer2/Add
onready var cancel_button = $StatusBox/StatusPoint/VBoxContainer/CenterContainer/HBoxContainer2/Cancel

func _ready():
	var group = get_tree().get_nodes_in_group("World")
	worldnode = group[0]
	stats = group[0].stats
	xp=worldnode.xp
	next_xp=worldnode.xp_next_level
	previous_xp=worldnode.xp_previous_level
	bar_xp.value = xp
	bar_xp.max_value = next_xp
	bar_xp.min_value = previous_xp
	level.text = "Lv. "+str(worldnode.level)
	pollen_tag.text = str(worldnode.stats_game["pollen"])
	fol_tag.text = str(worldnode.stats_game["fol"])
	conf_stats()
	

func conf_stats():
	poin = worldnode.main_point
	point_tag.text= str(poin)
	
	statsrep = {"maxhp":stats.maxhp,"maxpp":stats.maxpp,"attack":stats.attack,"defense":stats.defense,"speed":stats.speed,"aspeed":stats.attack_speed,"rs":stats.ratiospeeddec,"rw":stats.ratiowaterdec}
	
	maxhp_tag.text= str(stats.maxhp)
	maxpp_tag.text= str(stats.maxpp)
	attack_tag.text= str(stats.attack)
	defense_tag.text= str(stepify(stats.defense,0.1))
	speed_tag.text= str(stats.speed)
	aspeed_tag.text= str(stats.attack_speed)
	rs_tag.text = str(stats.ratiospeeddec)
	rw_tag.text = str(stats.ratiowaterdec*100)+" %"
	
	soil = stats.soil
	slippery = stats.slippery
	fertility = stats.fertility
	soil_tag.text = str(soil)
	slippery_tag.text = str(slippery)
	fertility_tag.text = str(fertility)
	
	maxhp_tag.add_color_override("font_color",Color.white)
	maxpp_tag.add_color_override("font_color",Color.white)
	attack_tag.add_color_override("font_color",Color.white)
	defense_tag.add_color_override("font_color",Color.white)
	speed_tag.add_color_override("font_color",Color.white)
	rs_tag.add_color_override("font_color",Color.white)
	rw_tag.add_color_override("font_color",Color.white)
	
	soil_tag.add_color_override("font_color",Color.white)
	slippery_tag.add_color_override("font_color",Color.white)
	fertility_tag.add_color_override("font_color",Color.white)

func set_disable_button(button,value):
	button.disabled = value

func button_check_poin():
	if poinuse<=0:
		set_disable_button(add_button,true)
		set_disable_button(cancel_button,true)

func _on_ProgressBar_mouse_entered():
	var instance = load("res://assets/scene/UI/Tooltip.tscn")
	tooltip=Global.instance_node(instance)
	tooltip.add_to_group("tooltip")
	Global.spawn_node_deferred(tooltip,get_tree().get_root().get_node("Game/GUI"))
	tooltip.set_tooltip(str(xp)+"/"+str(next_xp))

func _on_ProgressBar_mouse_exited():
	tooltip.queue_free()
	pass # Replace with function body.

func _on_soil_Up_pressed():
	if poin > 0:
		set_disable_button(add_button,false)
		set_disable_button(cancel_button,false)
		poin -= 1
		poinuse += 1
		soiluse += 1
		soil += 1
		soil_tag.text = str(soil)
		point_tag.text = str(poin)
		statsrep["maxhp"] = stats.maxhp+((soil-stats.soil)*3)
		statsrep["defense"] = stats.defense+((soil-stats.soil)*0.25)
		maxhp_tag.text = str(statsrep["maxhp"])
		defense_tag.text = str(stepify(statsrep["defense"],0.1))
		soil_tag.add_color_override("font_color",Color.green)
		maxhp_tag.add_color_override("font_color",Color.green)
		defense_tag.add_color_override("font_color",Color.green)

func _on_soil_Down_pressed():
	if (soiluse!=0):
		poin += 1
		poinuse -= 1
		soiluse -= 1
		soil -= 1
		button_check_poin()
		soil_tag.text = str(soil)
		point_tag.text = str(poin)
		statsrep["maxhp"] = stats.maxhp-((stats.soil-soil)*3)
		statsrep["defense"] = stats.defense-((stats.soil-soil)*0.25)
		defense_tag.text = str(stepify(statsrep["defense"],0.1))
		maxhp_tag.text = str(statsrep["maxhp"])
		if soil > stats.soil:
			soil_tag.add_color_override("font_color",Color.green)
		else:
			soil_tag.add_color_override("font_color",Color.white)
		if statsrep["maxhp"] > stats.maxhp:
			maxhp_tag.add_color_override("font_color",Color.green)
		else:
			maxhp_tag.add_color_override("font_color",Color.white)
		if statsrep["defense"] > stats.defense:
			defense_tag.add_color_override("font_color",Color.green)
		else:
			defense_tag.add_color_override("font_color",Color.white)

func _on_slippery_Up_pressed():
	if poin > 0:
		set_disable_button(add_button,false)
		set_disable_button(cancel_button,false)
		poin -= 1
		poinuse += 1
		slipperyuse += 1
		slippery += 1
		slippery_tag.text = str(slippery)
		point_tag.text = str(poin)
		statsrep["speed"] = stats.speed+((slippery-stats.slippery)*5)
		statsrep["rs"] = stats.ratiospeeddec-((slippery-stats.slippery)*0.005)
		speed_tag.text = str(statsrep["speed"])
		rs_tag.text = str(stepify(statsrep["rs"],0.001))
		slippery_tag.add_color_override("font_color",Color.green)
		speed_tag.add_color_override("font_color",Color.green)
		rs_tag.add_color_override("font_color",Color.green)

func _on_slippery_Down_pressed():
	if (slipperyuse!=0):
		poin += 1
		poinuse -= 1
		slipperyuse -= 1
		slippery -= 1
		slippery_tag.text = str(slippery)
		button_check_poin()
		point_tag.text = str(poin)
		statsrep["speed"] = stats.speed+((stats.slippery-slippery)*2.5)
		statsrep["rs"] = stats.ratiospeeddec-((slippery-stats.slippery)*0.01)
		
		speed_tag.text = str(statsrep["speed"])
		rs_tag.text = str(stepify(statsrep["rs"],0.001))
		if slippery > stats.slippery:
			slippery_tag.add_color_override("font_color",Color.green)
		else:
			slippery_tag.add_color_override("font_color",Color.white)
			
		if statsrep["speed"] > stats.speed:
			speed_tag.add_color_override("font_color",Color.green)
		else:
			speed_tag.add_color_override("font_color",Color.white)
		
		if statsrep["rs"] > stats.ratiospeeddec:
			rs_tag.add_color_override("font_color",Color.green)
		else:
			rs_tag.add_color_override("font_color",Color.white)

func _on_fertility_Up_pressed():
	if poin > 0:
		set_disable_button(add_button,false)
		set_disable_button(cancel_button,false)
		poin -= 1
		poinuse += 1
		fertilityuse += 1
		fertility += 1
		fertility_tag.text = str(fertility)
		point_tag.text = str(poin)
		statsrep["maxpp"] = stats.maxpp+((fertility-stats.fertility)*2)
		statsrep["attack"] = stats.attack+((fertility-stats.fertility)*0.5)
		maxpp_tag.text = str(statsrep["maxpp"])
		attack_tag.text=str(statsrep["attack"])
		fertility_tag.add_color_override("font_color",Color.green)
		maxpp_tag.add_color_override("font_color",Color.green)
		attack_tag.add_color_override("font_color",Color.green)

func _on_fertility_Down_pressed():
	if (fertilityuse!=0):
		poin += 1
		poinuse -= 1
		fertilityuse -= 1
		fertility -= 1
		button_check_poin()
		fertility_tag.text = str(fertility)
		point_tag.text = str(poin)
		statsrep["maxpp"] = stats.maxpp-((stats.fertility-fertility)*2)
		statsrep["attack"] = stats.attack-((stats.fertility-fertility)*0.5)
		maxpp_tag.text = str(statsrep["maxpp"])
		attack_tag.text=str(statsrep["attack"])
		if fertility > stats.fertility:
			fertility_tag.add_color_override("font_color",Color.green)
		else:
			fertility_tag.add_color_override("font_color",Color.white)
			
		if statsrep["maxpp"] > stats.maxpp:
			maxpp_tag.add_color_override("font_color",Color.green)
		else:
			maxpp_tag.add_color_override("font_color",Color.white)
		
		if statsrep["attack"] > stats.attack:
			attack_tag.add_color_override("font_color",Color.green)
		else:
			attack_tag.add_color_override("font_color",Color.white)

func _on_Add_pressed():
	if ((poinuse+poin)==worldnode.main_point):
		stats.soil += soiluse
		stats.slippery += slipperyuse
		stats.fertility += fertilityuse
		worldnode.main_point -= poinuse
		stats.update_stat()
		conf_stats()
		soiluse=0
		slipperyuse=0
		fertilityuse=0
		poinuse=0
		Global.create_alert("Stat has been increased!")
		button_check_poin()
	else:
		Global.create_alert("Error on point")

func _on_Cancel_pressed():
	soiluse=0
	slipperyuse=0
	fertilityuse=0
	poinuse=0
	poinuse = 0
	poin = worldnode.main_point
	conf_stats()
	button_check_poin()
	pass # Replace with function body.
