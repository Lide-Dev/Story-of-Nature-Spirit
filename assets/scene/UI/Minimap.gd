extends Control

export var zoom = 2 setget set_zoom

onready var grid = $PanelContainer/MarginContainer
onready var markerspawn = $PanelContainer/MarginContainer/Mark
#onready var alert_marker = $MarginContainer/Grid/AlertMarker

var playernode
var playerpos
var marker = []
var grid_scale
var node_map

func _ready():
	grid_scale = grid.rect_size / (get_viewport_rect().size * zoom)
#	$PanelContainer/MarginContainer/NavMapY.
	pass

func change_map(city,location):
	if is_instance_valid(node_map):
		node_map.queue_free()
	var path= load("res://assets/scene/Maps/"+city+"/"+location+"/Minimap.tscn")
	var node = Global.instance_node(path)
	Global.spawn_node(node,grid)
	node_map = node
	node_map.scale = grid.rect_size / (get_viewport_rect().size * zoom)

func set_zoom(value):
	zoom = clamp(value, 0.5, 5)
	grid_scale = grid.rect_scale/ (get_viewport_rect().size * zoom)
	
func _process(_delta):
	if marker.size() > 0:
		for mark in marker:
			if is_instance_valid(mark["node"]):
				if is_instance_valid(playernode):
					playerpos=playernode.position
				var obj_pos = (mark["node"].position-playerpos)*grid_scale + grid.rect_size / 2
				if (mark["type"]=="quest" or mark["type"]=="npc" or mark["type"]=="merchant" or mark["type"]=="blacksmith"):
					obj_pos.x = clamp(obj_pos.x, 0, grid.rect_size.x)
					obj_pos.y = clamp(obj_pos.y, 0, grid.rect_size.y)
				mark["mark"].position=obj_pos
			else:
				mark["mark"].queue_free()
				marker.erase(mark)
	if is_instance_valid(node_map):
		if is_instance_valid(playernode):
			playerpos=playernode.position
			node_map.position=(node_map.position-playerpos)*grid_scale + grid.rect_size / 2

func node_added(nodepath,type="enemy"):
	var path_mark = load("res://assets/scene/UI/Marker.tscn")
	var path_black = load("res://assets/scene/UI/MarkerBlacksmith.tscn")
	var path_loc = load("res://assets/scene/UI/MarkerLocation.tscn")
	var path_merchant = load("res://assets/scene/UI/MarkerMerchant.tscn")
	var path_quest = load("res://assets/scene/UI/MarkerQuest.tscn")
	var mark
	match type:
		"player":
			mark=Global.instance_node(path_mark)
			mark.frame=1
			mark.position = grid.rect_size / 2
			playernode=nodepath
		"enemy":
			mark=Global.instance_node(path_mark)
			mark.frame=0
			mark.position = nodepath.position
		"npc":
			mark=Global.instance_node(path_mark)
			mark.frame=2
			mark.position = nodepath.position
		"merchant":
			mark=Global.instance_node(path_merchant)
			mark.position = nodepath.position
		"blacksmith":
			mark=Global.instance_node(path_black)
			mark.position = nodepath.position
		"location":
			mark=Global.instance_node(path_loc)
			mark.position = nodepath.position
		"quest":
			mark=Global.instance_node(path_quest)
			mark.position = nodepath.position
	Global.spawn_node(mark,markerspawn)
	if type != "player":
		var dict = {"node":nodepath,"mark":mark , "type":type}
		marker.push_back(dict)

	
func delete_all_marker():
	for mark in marker:
		if mark["type"]!="player":
			mark["mark"].queue_free()
			marker.erase(mark)

func _on_Minimap_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("soom")
		if event.button_index == BUTTON_WHEEL_UP:
			self.zoom += 0.1
		if event.button_index == BUTTON_WHEEL_DOWN:
			self.zoom -= 0.1


func _on_PanelContainer_gui_input(event):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed):
		Global.create_alert("World Map still development. We are sorry about that.")
		
	pass # Replace with function body.
