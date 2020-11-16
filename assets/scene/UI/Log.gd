extends Control

func set_text(txt, timer=10):
#	var newtext = Label.new()
#	newtext.add_font_override("font", "res://assets/fonts/logtext.tres")
#	newtext.text=txt
#	newtext.autowrap=true
	var new_text=Global.instance_node(load("res://assets/scene/UI/LogText.tscn"))
	new_text.text = "> "+str(txt)
	new_text.timer = timer
	Global.spawn_node_deferred(new_text,$VBoxContainer)
