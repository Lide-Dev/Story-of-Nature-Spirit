extends Control

onready var bgm_slider = $VBoxContainer/BGM/HSlider
onready var sfx_slider = $VBoxContainer/SFX/HSlider
onready var bgm_volume = $VBoxContainer/BGM/HBoxContainer2/Volume
onready var sfx_volume = $VBoxContainer/SFX/HBoxContainer/Volume
onready var fps_check = $VBoxContainer/Other/FPS
onready var popup = $ConfirmationDialog
var game
var is_quit = false

func _ready():
	game = get_tree().get_root().get_node("Game")
	update()
	bgm_slider.value = MusicSystem.volume_bgm
	sfx_slider.value = MusicSystem.volume_sfx
	fps_check.pressed = Global.fps_mode

func update():
	bgm_volume.text = str(MusicSystem.volume_bgm)+"%"
	sfx_volume.text = str(MusicSystem.volume_sfx)+"%"

func _on_BGMSlider_value_changed(value):
	MusicSystem.volume_bgm = value
	update()

func _on_SFXSlider_value_changed(value):
	MusicSystem.volume_sfx = value
	update()

func _on_FPS_toggled(button_pressed):
	MusicSystem.set_sfx(MusicSystem.ui.INVENTORYSELECT)
	Global.fps_mode = button_pressed

func _on_Cancel_pressed():
	popup.hide()

func _on_About_pressed():
	popup.show()

func _on_CancelOut_pressed():
	hide()
	pass # Replace with function body.

func _on_Reset_pressed():
	var dir = Directory.new()
	if game.check_savegame():
		dir.remove("user://savegame.dat")
		Global.create_alert("Saved game has been deleted!")
		var contivisual = get_tree().get_root().get_node("Game/Menu/Menu/Visual/VBoxContainer/Continue")
		var conti = get_tree().get_root().get_node("Game/Menu/Menu/Button/VBoxContainer/Continue")
		conti.disabled = true
		contivisual.modulate = Color("565555")
		get_tree().get_root().get_node("Game/Menu").available_save = false
	else:
		Global.create_alert("Not have saved game!")
	
	pass # Replace with function body.
