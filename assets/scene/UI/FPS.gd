extends Label

var enable = true

func _ready():
	Global.connect("fps_changed",self,"option_fps")

func option_fps(value):
	enable = value
	if enable:
		show()
	else:
		hide()

func _process(_delta): 
	if enable:
		set_text(str("FPS: "+str(Engine.get_frames_per_second())))
