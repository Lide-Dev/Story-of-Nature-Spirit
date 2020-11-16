extends Control

signal delete_accepted(stk)

onready var button_cancel = $Delete/HBoxContainer2/Cancel
onready var button_accept = $Delete/HBoxContainer2/Accept
onready var namestack = $Delete/NameandStack
onready var stackinput = $Delete/HBoxContainer/LineEdit
onready var button_up = $Delete/HBoxContainer/Up
onready var button_down = $Delete/HBoxContainer/Down
onready var delete = $Delete
onready var shortcut = $Shortcut
onready var equip = $Equip
onready var shortcutoption = $Shortcut/CenterContainer/MenuButton
onready var shortcuttag = $Shortcut/Shortcut

var world
var gui
var stack = 0
var stackgui = 1
var nameitem = ""
var shortcutItem = {}

func _ready():
	hide()
	gui = get_tree().get_root().get_node("Game/GUI")
	world = get_tree().get_root().get_node("Game/World")
	shortcutoption.add_item("Shortcut 1")
	shortcutoption.add_item("Shortcut 2")
	shortcutoption.add_item("Shortcut 3")
	shortcutoption.add_item("Shortcut 4")
	shortcutoption.selected = 0
	shortcutItem = gui.loadedItem.duplicate()

func set_shortcut(item):
	nameitem = item
	if shortcutItem["Itembox1"] =="none":
		shortcuttag.text = "Shortcut: None"
	else:
		shortcuttag.text = "Shortcut: "+ DataImport.item_data[shortcutItem["Itembox1"]].real_name

func set_deleteitem(item,stk):
	stack = stk
	stackgui = 1
	nameitem = item
	namestack.text=DataImport.item_data[item].real_name+": "+str(stack)+" pcs"
	stackinput.set_text(str(stackgui))

func _on_LineEdit_text_change_rejected():
	stackinput.text=str(stack)

func _on_LineEdit_text_entered(new_text):
	if new_text.is_valid_integer() :
		if int(new_text) <= 1:
			stackinput.set_text("1")
		stackgui = int(new_text)
	else:
		stackinput.set_text(str(stack))
		stackgui = stack

func _on_Up_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.INVENTORYSELECT)
	if stackgui >= stack:
		stackinput.set_text("1")
		stackgui = 1
	else:
		stackgui += 1
		stackinput.set_text(str(stackgui))

func _on_Down_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.INVENTORYDESELECT)
	if stackgui <= 1:
		stackinput.set_text(str(stack))
		stackgui = stack
	else:
		stackgui -= 1
		stackinput.set_text(str(stackgui))

func _on_Accept_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if stackgui > stack:
		Global.create_alert("Error on delete item.")
		hide()
	else:
		Global.create_alert("Delete "+DataImport.item_data[nameitem].real_name+" "+str(stackgui)+" pcs.")
		emit_signal("delete_accepted",stackgui)
		hide()

func _on_Cancel_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	hide()
	delete.hide()
	shortcut.hide()
	equip.hide()


func _on_shortcut_Accept_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	shortcutItem["Itembox"+str(shortcutoption.selected+1)] = nameitem
	gui.set_loadedItem(shortcutItem)
	hide()

func _on_MenuButton_item_selected(id):
	MusicSystem.set_sfx(MusicSystem.ui.INVENTORYSELECT)
	var new_id = id+1
	var item = shortcutItem["Itembox"+str(new_id)]
	if item != "none":
		shortcuttag.text = "Shortcut: "+ DataImport.item_data[item].real_name
	else:
		shortcuttag.text = "Shortcut: None"

func _on_OrbR_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if world.equipment["orb2"] == "":
		world.set_equipment("orb2",nameitem)
	else:
		world.add_item(world.equipment["orb2"],1)
		world.set_equipment("orb2",nameitem)

	world.set_useitem(nameitem)
	get_node("../Content").check_emptyitem()
	hide()
	delete.hide()
	shortcut.hide()
	equip.hide()

func _on_OrbL_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if world.equipment["orb1"] == "":
		world.set_equipment("orb1",nameitem)
	else:
		world.add_item(world.equipment["orb1"],1)
		world.set_equipment("orb1",nameitem)
	world.set_useitem(nameitem)
	get_node("../Content").check_emptyitem()
	hide()
	delete.hide()
	shortcut.hide()
	equip.hide()
	pass # Replace with function body.
