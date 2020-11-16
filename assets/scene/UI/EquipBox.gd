extends PanelContainer

signal item_toggled(node)

var item_icon = 11 setget set_icon
var name_item = "None" setget set_nameitem
export (String) var key = ""
export (String) var type = "Head" 

func set_icon(icn):
	item_icon = icn
	$Sprite.frame = item_icon

func set_nameitem(nm):
	name_item=nm
	if (name_item != "None"):
		item_icon = DataImport.item_data[name_item].icon
		$Sprite.frame = item_icon
	else:
		item_icon = 11
		$Sprite.frame = item_icon

func set_pressed(value):
	$Button.pressed = value


func _on_Item0_mouse_entered():
	if name_item != "None":
		Global.create_tooltip(DataImport.item_data[name_item].real_name)

func _on_Item0_mouse_exited():
	Global.delete_tooltip()

func _on_Button_toggled(_button_pressed):
	if name_item != "None":
		if _button_pressed:
			MusicSystem.set_sfx(MusicSystem.ui.INVENTORYSELECT)
		else:
			MusicSystem.set_sfx(MusicSystem.ui.INVENTORYDESELECT)
	if name_item != "None":
		emit_signal("item_toggled",self)
	else:
		$Button.pressed = false

func _on_Button_mouse_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)
	pass # Replace with function body.
