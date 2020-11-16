extends YSort

onready var dialog = $Dialog

var scene =0

var radish_text = [
	"The end of your glory ends here, Fronne",
	["SILENCE!!!", "I don't care what I've done now."," I will lock you up in the Void Prison in my place!"],
]
var system_text = [
	"Fronne has been moved to Void Prison. But Fronne had prepared a plan if he didn't exist when the world was threatened."
]
var fronne_text = [
	"Do you know? What you do will destroy the balance of this world.",
]

func _ready():
	MusicSystem.set_bgm("res://assets/bgm/Into-Battle_v001.ogg")
	yield(get_tree().create_timer(2),"timeout")
	dialog.set_dialog("Radish",radish_text[0],"none",true)
	scene += 1
	$Timer.start(1)


func _on_Timer_timeout():
	if !dialog.dialog_show:
		match str(scene):
			"1":
				dialog.set_dialog("Fronne",fronne_text[0],"none",true)
			"2":
				dialog.set_dialog("Radish",radish_text[1],"none",true)
			"3":
				dialog.set_dialog("System",system_text[0],"none",true)
			_:
				MusicSystem.free_bgm()
				$Timer.stop()
				Global.spawn_node(Global.instance_node("res://assets/scene/Cinematic/Introduction/Cinematic_Intro1.tscn"),get_tree().get_root().get_node("Game"))
				$Dialog.remove_from_group("Dialog")
				queue_free()
				
		scene += 1
	pass # Replace with function body.
