extends Control

var posit = "bottom"

func set_tooltip(text,pos="bottom"):
	posit = pos
	$PanelContainer/Label.text = str(text)

func _process(_delta):
	if posit == "bottom":
		$PanelContainer.rect_position = get_local_mouse_position()+Vector2(5,5)
	else:
		$PanelContainer.rect_position = get_local_mouse_position()+Vector2(5,-65)

func delete():
	queue_free()
