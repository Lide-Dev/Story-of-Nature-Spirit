extends Control

signal dialog_completed

onready var dialogtext =$DialogTexture/DialogValue
onready var npcname = $NameTexture/NameValue
onready var picture= $PictureNPC
onready var buttonopt = $Option/ScrollContainer/CenterContainer/VBoxContainer/Button
onready var optioncontainer = $Option
var line_txt = 0
var dialog_show = false
var first_use = true
var callback
var optsize
var optdialog = false
var buttonlist = []
var optionselect
var is_array = false
var arr_text = []
var current_text = ""
var text_count = 1

func _ready():
	hide()

func set_dialog(namenpc,text,path_picture="none",show = false):
	text_count = 1
	print(text_count)
	if typeof(text) == TYPE_ARRAY:
		print("ARRAY CHAT")
		is_array = true
		arr_text = text
		current_text = arr_text[text_count-1]
		dialogtext.text = str(current_text)
		text_count += 1
		print(text_count)
	else:
		print("NORMAL CHAT")
		dialogtext.text = str(text)
	npcname.text = str(namenpc)
	if path_picture != "none":
		picture.texture = load(path_picture)
	else:
		picture.texture = null
	if show:
		dialog_visible(true)
		print(dialog_show)

func set_option_dialog(namenpc,text,option:Array,path_picture="none"):
	text_count = 1
	if option.size() > 1:
		optsize=option.size()
		for opt in option:
			var btn = buttonopt.duplicate(8)
			btn.show()
			btn.text = opt
			Global.spawn_node(btn,$Option/ScrollContainer/CenterContainer/VBoxContainer)
			btn.connect("pressed",self,"option_selected",[btn])
			btn.connect("mouse_entered",self,"option_entered")
			buttonlist.push_back(btn)
	elif option.size() == 1:
		optsize=option.size()
		var btn = buttonopt.duplicate(8)
		btn.show()
		btn.text=option[0]
		Global.spawn_node(btn,$Option/ScrollContainer/CenterContainer/VBoxContainer)
		btn.connect("pressed",self,"option_selected",[btn])
		btn.connect("mouse_entered",self,"option_entered")
		buttonlist.push_back(btn)
	else:
		print ("INVALID COMMAND REQUEST")
	print(text_count)
	if typeof(text) == TYPE_ARRAY:
		print("ARRAY CHAT")
		is_array = true
		arr_text = text
		current_text = arr_text[text_count-1]
		dialogtext.text = str(current_text)
		text_count += 1
		print(text_count)
	else:
		print("NORMAL CHAT")
		dialogtext.text = str(text)
	npcname.text = str(namenpc)
	if path_picture != "none":
		picture.texture = load(path_picture)
	else:
		picture.texture = null
	dialog_visible(true)
	optdialog = true

func _input(event):
	if dialog_show:
		if event.is_action_pressed("ui_accept"):
			single_dialog()
				

func single_dialog():
	if line_txt >= dialogtext.get_line_count()-2:
#				print("CLOSE")
#		if optdialog:
#			print("Option Show")
#			optioncontainer.show()
#		else:
#			if is_array:
#				text_count+=1
#			print("Dialog Close")
#			dialog_visible(false)
#			emit_signal("dialog_completed")
		if first_use:
			$Icon.hide()
			first_use = false
		if (is_array and text_count <= arr_text.size()):
			current_text = arr_text[text_count-1]
			print("Index - "+str(text_count-1)+" : "+current_text)
			dialogtext.text = current_text
			text_count+=1
		elif optdialog:
			print("Option Show")
			optioncontainer.show()
		else:
			print("Dialog Close")
			dialog_visible(false)
			emit_signal("dialog_completed")
	elif dialogtext.get_line_count() > 4 :
		line_txt += 4
#				print("Skip"+str(line_txt))
		dialogtext.lines_skipped =line_txt
		if dialogtext.get_line_count()-line_txt<4 :
			$Icon2.hide()
		if first_use:
			$Icon.hide()
			first_use = false
	else:
		if (is_array and text_count <= arr_text.size()):
			current_text = arr_text[text_count-1]
			print("Index - "+str(text_count-1)+" : "+current_text)
			dialogtext.text = current_text
			text_count+=1
		elif optdialog:
			print("Option Show")
			optioncontainer.show()
		else:
			print("Dialog Close")
			dialog_visible(false)
			emit_signal("dialog_completed")

func dialog_visible(value:bool=true):
	if value:
		get_tree().paused = true
		if dialogtext.get_line_count() > 4:
			$Icon2.show()
		show()
#		get_tree().get_root().get_node("Game").interact_npc = true
		dialog_show = true
	else:
		if is_array:
			if text_count > arr_text.size():
				print("ARRAY FINISH")
				is_array=false
				arr_text = []
				text_count = 1
		optioncontainer.hide()
		for btn in buttonlist:
			btn.queue_free()
		buttonlist.clear()
		get_tree().paused = false
		hide()
		dialog_show = false
#		get_tree().get_root().get_node("Game").interact_npc = false
		dialogtext.lines_skipped = 0
		line_txt = 0

func option_selected(btn):
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	optionselect=buttonlist.find(btn)
	optdialog = false
	print("CLOSE")
	dialog_visible(false)
	emit_signal("dialog_completed")
	
func option_entered():
	MusicSystem.set_sfx(MusicSystem.ui.SWITCH)
