extends PanelContainer

signal item_toggled(node)

var item_icon = 11 setget set_icon
var name_item = "None" setget set_nameitem
var stack = 0 setget set_stack

func set_icon(icn):
	item_icon = icn
	$Sprite.frame = item_icon

func set_nameitem(nm):
	name_item=nm
	item_icon = DataImport.item_data[name_item].icon
	$Sprite.frame = item_icon

func set_pressed(value):
	$Button.pressed = value

func set_stack(stck):
	stack=stck
	$Stack.text = str(stack)

func _on_Item0_mouse_entered():
	if name_item != "None":
		Global.create_tooltip(DataImport.item_data[name_item].real_name)

func _on_Item0_mouse_exited():
	Global.delete_tooltip()

func _on_Button_toggled(_button_pressed):
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
