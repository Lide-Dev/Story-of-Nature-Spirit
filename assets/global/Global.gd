extends Node

signal fps_changed(val)

var development = true
var fps_mode =true setget set_fps

var txtdmg = preload("res://assets/scene/Effect/TextDamage.tscn")
var alert = preload("res://assets/scene/UI/Alert.tscn")

func instance_node(node,location=null):
	if typeof(node) == TYPE_STRING:
		node = load(node)
	var node_instance = node.instance()
	
	if !location==null:
		node_instance.global_position = location
	
	return node_instance

func set_fps(value):
	fps_mode = value
	emit_signal("fps_changed",fps_mode)

func debug_showtype(value):
	var builtin_type_names = ["nil", "bool", "int", "real", "string", "vector2", "rect2", "vector3", "maxtrix32", "plane", "quat", "aabb",  "matrix3", "transform", "color", "image", "nodepath", "rid", null, "inputevent", "dictionary", "array", "rawarray", "intarray", "realarray", "stringarray", "vector2array", "vector3array", "colorarray", "unknown"]
	return (typeof(value))

func spawn_node(node,parent):
	parent.add_child(node)
	
func spawn_node_deferred(node,parent):
	parent.call_deferred("add_child",node)

func bullet_damage(target,source,wprotect=false,value=0):
	var t_stat= target.stats 
#	print ("attack = "+String(source.attack*source.multiplier)+ " Defense = "+String(t_stat.defense*2))
	var calc
	if (wprotect && t_stat.wp > 0):
		calc = ((source.attack*source.multiplier)-(t_stat.defense*2))
		var wp = t_stat.wp - calc
		calc -= t_stat.wp/(2.25-value)
		if (wp >0):
			t_stat.wp -= wp
		else:
			t_stat.wp = 0
	else:
		calc = ((source.attack*source.multiplier)-(t_stat.defense*2))
	if (calc<=0):
		calc = 0
	create_txt_damage(target.global_position,int(calc),t_stat.maxhp)
	t_stat.hp -= int(calc)
	return calc

func melee_damage(target,source,wprotect=false,value=0):
	var t_stat= target.stats
#	print ("attack = "+String(source.attack)+ " Defense = "+String(t_stat.defense*2))
	var calc
	if (wprotect && t_stat.wp > 0):
		calc = (source.attack-(t_stat.defense*2))
		print(" first damaged "+str(calc)+" wp "+str(t_stat.wp))
		var wp = t_stat.wp - calc
		calc -= t_stat.wp/(2.25-value)
		print("WP decrease by protect "+str(wp)+" and second damaged "+str(calc))
		if (wp >0):
			t_stat.wp -= wp
		else:
			t_stat.wp = 0
	else:
		calc = (source.attack-(t_stat.defense*2))
	if (calc<=0):
		calc = 0
	t_stat.hp -= int(calc)
	return int(calc)
	
func create_txt_damage(target_position,calc,maxhp):
	var txt =instance_node(txtdmg,target_position+Vector2(0,-30))
	txt.damage = calc
	txt.hp = maxhp
	spawn_node_deferred(txt,get_tree().get_root())

func create_txt(position,text):
	var txt =instance_node(txtdmg,position+Vector2(0,-30))
	txt.damage = text
	spawn_node_deferred(txt,get_tree().get_root())

func create_alert(text,time=5):
	get_tree().call_group("Alert","alert_spawning")
	var node = instance_node(alert)
	node.add_to_group("Alert")
	if is_instance_valid(get_tree().get_root().get_node("Game/GUI")):
		spawn_node(node,get_tree().get_root().get_node("Game/GUI"))
	else:
		spawn_node(node,get_tree().get_root().get_node("Game/Loading"))
	node.set_alert(text,time)
#	get_tree().call_group("Alert","",)

func create_tooltip(text,pos="bottom"):
	var node = Global.instance_node(load("res://assets/scene/UI/Tooltip.tscn"))
	node.set_tooltip(text,pos)
	node.add_to_group("tooltip")
	Global.spawn_node_deferred(node,get_tree().get_root().get_node("Game/GUI"))

func delete_tooltip():
	get_tree().call_group("tooltip","delete")
