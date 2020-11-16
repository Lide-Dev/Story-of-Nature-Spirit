extends Control

onready var bgm_slider = $VBoxContainer/BGM/HSlider
onready var sfx_slider = $VBoxContainer/SFX/HSlider
onready var bgm_volume = $VBoxContainer/BGM/HBoxContainer2/Volume
onready var sfx_volume = $VBoxContainer/SFX/HBoxContainer/Volume
onready var fps_check = $VBoxContainer/Other/FPS
onready var save_btn = $VBoxContainer/Save/Save
onready var mainmenu_btn = $VBoxContainer/Save/MainMenu
onready var popup = $ConfirmationDialog
onready var popupquit = $ConfirmationDialog/VBoxContainer
onready var popupoverwrite = $ConfirmationDialog/VBoxContainer2
onready var popupquit_btn = $ConfirmationDialog/VBoxContainer/HBoxContainer/Quit
onready var popupquitsave_btn = $ConfirmationDialog/VBoxContainer/HBoxContainer/QuitSave
onready var popupcancel_btn = $ConfirmationDialog/VBoxContainer/HBoxContainer/Cancel
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

func _on_Save_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if game.check_savegame():
		popup.show()
		popupoverwrite.show()
		popupquit.hide()
		is_quit = false
	else:
		game.save_game()
	

func _on_MainMenu_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	popup.show()
	popupquit.show()
	pass # Replace with function body.

func _on_Quit_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	game.quit_game()
	pass # Replace with function body.

func _on_QuitSave_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if game.check_savegame():
		print("QuitSave "+str(game.check_savegame()))
		popupquit.hide()
		popup.show()
		popupoverwrite.show()
		is_quit = true
	else:
		game.save_game()
		game.quit_game()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	pass # Replace with function body.

func _on_Cancel_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	popup.hide()
	popupquit.hide()
	popupoverwrite.hide()
	is_quit = false

func _on_Overwrite_pressed():
	MusicSystem.set_sfx(MusicSystem.ui.MENUGAMESELECT)
	if is_quit:
		game.save_game()
		game.quit_game()
		MusicSystem.set_sfx(MusicSystem.ui.MENUGAMECANCEL)
	else:
		game.save_game()
		popup.hide()
		popupquit.hide()
		popupoverwrite.hide()
	
