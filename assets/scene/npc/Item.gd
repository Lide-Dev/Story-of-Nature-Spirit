extends StaticBody2D

var limit_up = true
var limit_color = true
var alpha=1
var name_item
var pickable = true
onready var icon = $Sprite
onready var timer = $Lifespan

func _ready():
	add_to_group("Item")
	icon.frame = DataImport.item_data[name_item].icon
	if !pickable:
		set_collision_layer_bit(16,0)
	
func _process(_delta):
	if limit_up:
		$Sprite.position += Vector2(0,0.2)
		if $Sprite.position >= Vector2(0,10):
			limit_up = false
	else :
		$Sprite.position -= Vector2(0,0.2)
		if $Sprite.position <= Vector2(0,0):
			limit_up = true
	if timer.time_left <= 5:
		if limit_color:
			alpha -= 0.1
			$Sprite.modulate = Color(0,0,0,alpha)
			if alpha <= 0:
				limit_color =false
		else:
			alpha += 0.1
			$Sprite.modulate = Color(255,255,255,alpha)
			if alpha >= 1:
				limit_color =true

func _on_Lifespan_timeout():
	queue_free()
	pass # Replace with function body.

func delete_all_item():
	var delete=get_tree().get_nodes_in_group("Item")
	for value in delete:
		value.remove_from_group("Item")
		value.queue_free()
	
