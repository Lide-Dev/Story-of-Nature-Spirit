extends KinematicBody2D

export (String,"People","Object","Merchant","Blacksmith","Alchemist") var npc_type = "People"
var npc_class = ""
export (Array,String) var npc_quest
export (Resource) var resource_npc
####======================================================

export (String) var alias_name = ""
export (bool) var is_door=false
export (String, "StandDown","StandUp","StandRight","StandLeft") var anim = "StandDown"
export (Array,String) var item_buy

var name_npc
var text
var player=null
var interactsystem
var path
var file = File.new()

func _ready():
	match npc_type:
		"People":
			get_tree().call_group("mark_system","node_added",self,"npc")
		"Alchemist":
			get_tree().call_group("mark_system","node_added",self,"npc")
		"Merchant":
			get_tree().call_group("mark_system","node_added",self,"merchant")
		"Blacksmith":
			get_tree().call_group("mark_system","node_added",self,"blacksmith")
		
	var node= get_tree().get_nodes_in_group("InteractSystem")
	interactsystem = node[0]
	var pathins = load("res://assets/scene/npc/"+alias_name+"/sprite.tscn")
	var n = Global.instance_node(pathins)
	Global.spawn_node(n,self)
	path = "res://assets/img/character/npc/"+alias_name+".png"
	var valid = file.file_exists(path)
	if !valid:
		path = "none"
	
	npc_class = alias_name
	if alias_name != "":
		name_npc = DataImport.npc_data[alias_name].name
		$Label.text=name_npc
	else:
		name_npc = "System"
		$Label.text="???"

func _unhandled_input(event):
	if player != null:
		if event.is_action_pressed("ui_accept"):
			MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
			if resource_npc.greeting:
				set_process_unhandled_input(false)
				var type
				match resource_npc.greeting_type:
					"single":
						type = interactsystem.type.SINGLE
					"branch":
						type = interactsystem.type.BRANCH
					"option":
						type = interactsystem.type.OPTION
				print(resource_npc.greeting_option)
				interactsystem.resource = resource_npc
				interactsystem.quest_available = npc_quest
				interactsystem.alias_name = alias_name
				interactsystem.callback = resource_npc.greeting_callback.duplicate()
				interactsystem.bye = resource_npc.bye
				interactsystem.greeting = resource_npc.greeting
				if npc_type=="Merchant":
					interactsystem.item_merchant=item_buy
				interactsystem.set_interact(
					name_npc,
					path,
					alias_name,
					type,
					resource_npc.greeting_option,
					"",
					"greet")
				$Check.start(0.5)

func _on_Interact_body_entered(body):
	player= body

func _on_Interact_body_exited(_body):
	player=null
	pass # Replace with function body.

func _on_Check_timeout():
	if interactsystem.get_interact_status() == interactsystem.status.IDLE:
		$Check.stop()
		set_process_unhandled_input(true)
		print("INTERACT FINISH")
	pass # Replace with function body.
