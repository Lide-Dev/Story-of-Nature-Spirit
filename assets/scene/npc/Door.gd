extends StaticBody2D

export (String,"People","Object") var npc_type = "Object"
var npc_class = "Door"
####======================================================
export  (String,"locked","merchant","blacksmith","alchemist","unlocked") var type_door = "locked"
export (String) var city = "" 
export (String) var to_location = "" 
export (String) var from = ""
export (String) var sell = ""
export (int) var anim_type = 1
var player_interact = false
var door_process = false
var process_complete = false
var gui
var player
var merchantpath = "res://assets/img/character/npc/Umion.png"
var alchemistpath = "res://assets/img/character/npc/Umion.png"
var blacksmithpath = "res://assets/img/character/npc/Roe.png"

func _ready():
	$AnimatedSprite.animation = "door"+str(anim_type)
	gui = get_node("/root/Game/GUI")
	var node = get_tree().get_nodes_in_group("player")
	player= node[0]
	if type_door == "blacksmith":
		get_tree().call_group("mark_system","node_added",self,"blacksmith")
	elif type_door == "merchant":
		get_tree().call_group("mark_system","node_added",self,"merchant")
	elif type_door == "unlocked":
		get_tree().call_group("mark_system","node_added",self,"location")
	else:
		get_tree().call_group("mark_system","node_added",self,"npc")

func _unhandled_input(event):
	if (event.is_action_pressed("ui_accept") and player_interact):
		player.state = player.LOADING
		match type_door:
			"locked":
				get_tree().call_group("Dialog","set_dialog","System","It's Locked!","none",true)
			"merchant":
				$AnimatedSprite.play( "door"+str(anim_type),false)
				get_tree().call_group("Dialog","set_dialog","Myrad","Shopping Time!",merchantpath,true)
				
			"blacksmith":
				$AnimatedSprite.play( "door"+str(anim_type),false)
				get_tree().call_group("Dialog","set_dialog","Roe","Yo! Wanna see a new Weapon?",blacksmithpath,true)
				
			"alchemist":
				$AnimatedSprite.play( "door"+str(anim_type),false)
				get_tree().call_group("Dialog","set_dialog","Umiom","Ah sorry but my pot has been snared. So i can't help you to make a potion.",merchantpath,true)
				
			"unlocked":
				$AnimatedSprite.play( "door"+str(anim_type),false)
				get_tree().call_group("Dialog","set_dialog","System","To "+city+" "+to_location,"none",true)
		$Check.start(1)
		set_process_unhandled_input(false)

func _on_Door_area_entered(area):
	player_interact = true

func _on_Door_area_exited(area):
	player_interact = false

func _on_Check_timeout():
	var dialog =get_tree().get_nodes_in_group("Dialog")
	if !dialog[0].dialog_show and !door_process:
		door_process = true
		get_tree().call_group("Game","set_interactnpc",true)
		get_tree().get_root().get_node("Game").interact_npc = true
		print("Dialog Finish")
		match type_door:
			"merchant":
				var pathopen = load("res://assets/scene/UI/MerchantUI.tscn")
				var node =Global.instance_node(pathopen)
				var array=sell.split(",",true,0)
				var item_sell = {}
				for arr in array:
					item_sell[arr]={"stack":128}
				node.item_buy = item_sell
				node.npc_event = self
				Global.spawn_node_deferred(node,gui)
			"blacksmith":
				var pathopen = load("res://assets/scene/UI/MerchantUI.tscn")
				var node =Global.instance_node(pathopen)
				var array=sell.split(",",true,0)
				var item_sell = {}
				for arr in array:
					item_sell[arr]={"stack":128}
				node.item_buy = item_sell
				node.npc_event = self
				Global.spawn_node_deferred(node,gui)
				process_complete = true
			"alchemist":
				process_complete = true
			"locked":
				process_complete = true
			"unlocked":
				process_complete = true
		$AnimatedSprite.play( "door"+str(anim_type),true)
			
	if process_complete:
		get_tree().call_group("Game","set_interactnpc",false)
		player.state = player.MOVE
		get_tree().paused=false
		get_tree().get_root().get_node("Game").interact_npc = false
		$Check.stop()
		yield(get_tree().create_timer(1),"timeout")
		process_complete = false
		door_process = false
		set_process_unhandled_input(true)
	
