extends YSort

onready var pathfollow= $Path2D/PathFollow2D
onready var dialog = $CanvasLayer/Dialog
var maxpath = 525.89
var scene = 0
var velocity = 0
var dialog_active = false
var img_path = "res://assets/img/character/npc/listia.png"
var listia_txt = [
	["A beautiful day","I need to water my plants."],
	["Fairy Egg !?","This power can only be used by Fronne.","Is this what Fronne talked to me at that time?","My feeling says that the worst thing will happen. Is Fronne okay there?","I hope you are well","Before that I need to take care of this egg container.","I will take him to the tree house"]
]

func _ready():
	MusicSystem.set_bgm("res://assets/bgm/Once-Around-the-Kingdom_Looping.ogg")
	velocity = maxpath/600
	$CanvasLayer/ColorRect.color=Color(0,0,0)
	$AnimationPlayer.play("Scene0_FadeIn")
	$AnimaSprite.play("Listia")
	

func increase_scene():
	scene += 1

func _process(delta):
	if (pathfollow.unit_offset >= 0.59 and scene == 1):
		scene =2
		dialog.set_dialog("Listia",listia_txt[0],img_path,true)
		dialog_active = true
	elif (pathfollow.unit_offset >= 0.9 and scene == 3):
		scene =4
		$AnimationPlayer.play("Scene1_Suprising")
		yield(get_tree().create_timer(1),"timeout")
		dialog_active = true
		dialog.set_dialog("Listia",listia_txt[1],img_path,true)
	elif(scene==1):
		pathfollow.offset += velocity
	elif(scene==3):
		$Listia/Position2D/Listia.frame = 1
		pathfollow.offset += velocity
	elif(scene==5):
		$AnimationPlayer.play("Scene5_fadeout")
		scene+=1
	elif(scene==7):
		dialog.remove_from_group("Dialog")
		MusicSystem.free_bgm()
		Global.spawn_node(Global.instance_node("res://assets/scene/Cinematic/Introduction/Cinematic_Intro2.tscn"),get_tree().get_root().get_node("Game"))
		queue_free()
	if dialog_active:
		if !dialog.dialog_show:
			dialog_active =false
			scene +=1
			print(scene)
