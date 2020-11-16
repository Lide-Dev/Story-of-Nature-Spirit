extends Control

signal container_changed(container)

onready var container = $SplitMenu
var statenode
var color_toggle = "514d4d"
enum {
	STATUS,
	EQUIPMENT,
	SKILL,
	INVENTORY,
	QUEST,
	OPTION
}
var container_active = STATUS 
var button_toggle

func _ready():
	button_toggle = $SplitMenu/Tabs/Status
	$SplitMenu/Tabs/Status.connect("mouse_entered",self,"_on_mouse_entered",[$SplitMenu/Tabs/Status])
	$SplitMenu/Tabs/Equipment.connect("mouse_entered",self,"_on_mouse_entered",[$SplitMenu/Tabs/Equipment])
	$SplitMenu/Tabs/Skill.connect("mouse_entered",self,"_on_mouse_entered",[$SplitMenu/Tabs/Skill])
	$SplitMenu/Tabs/Inventory.connect("mouse_entered",self,"_on_mouse_entered",[$SplitMenu/Tabs/Inventory])
	$SplitMenu/Tabs/Quest.connect("mouse_entered",self,"_on_mouse_entered",[$SplitMenu/Tabs/Quest])
	$SplitMenu/Tabs/Option.connect("mouse_entered",self,"_on_mouse_entered",[$SplitMenu/Tabs/Option])
	
	$SplitMenu/Tabs/Status.connect("mouse_exited",self,"_on_mouse_exited",[$SplitMenu/Tabs/Status])
	$SplitMenu/Tabs/Equipment.connect("mouse_exited",self,"_on_mouse_exited",[$SplitMenu/Tabs/Equipment])
	$SplitMenu/Tabs/Skill.connect("mouse_exited",self,"_on_mouse_exited",[$SplitMenu/Tabs/Skill])
	$SplitMenu/Tabs/Inventory.connect("mouse_exited",self,"_on_mouse_exited",[$SplitMenu/Tabs/Inventory])
	$SplitMenu/Tabs/Quest.connect("mouse_exited",self,"_on_mouse_exited",[$SplitMenu/Tabs/Quest])
	$SplitMenu/Tabs/Option.connect("mouse_exited",self,"_on_mouse_exited",[$SplitMenu/Tabs/Option])

func _on_mouse_entered(btn):
	if button_toggle != btn:
		$Tween.remove(btn)
		$Tween.interpolate_property(btn,"rect_rotation",0,2,0.2,Tween.TRANS_QUAD,Tween.EASE_IN)
		$Tween.interpolate_property(btn,"rect_rotation",2,0,0.2,Tween.TRANS_QUAD,Tween.EASE_IN,0.2)
		$Tween.interpolate_property(btn,"rect_rotation",0,-2,0.2,Tween.TRANS_QUAD,Tween.EASE_IN,0.4)
		$Tween.interpolate_property(btn,"rect_rotation",-2,0,0.2,Tween.TRANS_QUAD,Tween.EASE_IN,0.6)
		$Tween.repeat = true
		$Tween.start()

func _on_mouse_exited(btn):
	btn.rect_rotation = 0
	$Tween.remove(btn)

func reset():
	if is_instance_valid(button_toggle):
		button_toggle.modulate = Color.white
	button_toggle = $SplitMenu/Tabs/Status
	button_toggle.modulate = Color(color_toggle)
	container_active=STATUS

func _on_Inventory_pressed():
	if container_active != INVENTORY:
		$Tween.stop_all()
		$Tween.reset_all()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
		button_toggle.modulate = Color.white
		statenode.queue_free()
		button_toggle = $SplitMenu/Tabs/Inventory
		var node = load("res://assets/scene/UI/InventoryContainer.tscn")
		statenode =  Global.instance_node(node)
		emit_signal("container_changed",statenode)
		Global.spawn_node(statenode,container)
		container_active=INVENTORY
		button_toggle.modulate = Color(color_toggle)

func _on_Status_pressed():
	if container_active != STATUS:
		$Tween.stop_all()
		$Tween.reset_all()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
		button_toggle.modulate = Color.white
		statenode.queue_free()
		button_toggle = $SplitMenu/Tabs/Status
		var node = load("res://assets/scene/UI/StatusContainer.tscn")
		statenode =  Global.instance_node(node)
		emit_signal("container_changed",statenode)
		Global.spawn_node(statenode,container)
		container_active=STATUS
		button_toggle.modulate = Color(color_toggle)

func _on_Quest_pressed():
	if container_active != QUEST:
		$Tween.stop_all()
		$Tween.reset_all()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
		button_toggle.modulate = Color.white
		statenode.queue_free()
		button_toggle = $SplitMenu/Tabs/Quest
		var node = load("res://assets/scene/UI/QuestContainer.tscn")
		statenode =  Global.instance_node(node)
		emit_signal("container_changed",statenode)
		Global.spawn_node(statenode,container)
		container_active=QUEST
		button_toggle.modulate = Color(color_toggle)

func _on_Equipment_pressed():
	if container_active != EQUIPMENT:
		$Tween.stop_all()
		$Tween.reset_all()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
		button_toggle.modulate = Color.white
		statenode.queue_free()
		button_toggle = $SplitMenu/Tabs/Equipment
		var node = load("res://assets/scene/UI/EquipmentContainer.tscn")
		statenode =  Global.instance_node(node)
		statenode.menu = self
		emit_signal("container_changed",statenode)
		Global.spawn_node(statenode,container)
		container_active=EQUIPMENT
		button_toggle.modulate = Color(color_toggle)

func _on_Option_pressed():
	if container_active != OPTION:
		$Tween.stop_all()
		$Tween.reset_all()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
		button_toggle.modulate = Color.white
		statenode.queue_free()
		button_toggle = $SplitMenu/Tabs/Option
		var node = load("res://assets/scene/UI/OptionContainer.tscn")
		statenode = Global.instance_node(node)
		emit_signal("container_changed",statenode)
		Global.spawn_node(statenode,container)
		container_active=OPTION
		button_toggle.modulate = Color(color_toggle)
	pass # Replace with function body.

func _on_Skill_pressed():
	if container_active != SKILL:
		$Tween.stop_all()
		$Tween.reset_all()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
		button_toggle.modulate = Color.white
		statenode.queue_free()
		button_toggle = $SplitMenu/Tabs/Skill
		var node = load("res://assets/scene/UI/SkillContainer.tscn")
		statenode = Global.instance_node(node)
		emit_signal("container_changed",statenode)
		Global.spawn_node(statenode,container)
		container_active=SKILL
		button_toggle.modulate = Color(color_toggle)
	pass # Replace with function body.
