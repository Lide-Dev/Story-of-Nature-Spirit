extends YSort

func item_drop(enemy,pos):
	randomize()
	var item = DataImport.enemy_data[enemy].drop_item
	if item != "none":
		item = item.split(",",true,0)
		for name_item in item :
			var random = rand_range(1,1000)
			var x_pos = rand_range(-40,40)
			var y_pos = rand_range(-40,40)
			var chance = 0
			match str(DataImport.item_data[name_item].rarity):
				"0":
					chance = 1000
				"1":
					chance = 400
				"2":
					chance = 100
				"3":
					chance = 30
				"4":
					chance = 5
			print(chance)
			if random <= chance:
				var load_item = load("res://assets/scene/npc/Item.tscn")
				var node=Global.instance_node(load_item, pos+Vector2(x_pos,y_pos))
				node.name_item = name_item
				node.z_index=3
				Global.spawn_node_deferred(node,self)

func spawn_enemydeath(pos,flip,enemy):
	print(pos)
	var death = load("res://assets/scene/enemy/main_system/EnemyDeath.tscn")
	death=Global.instance_node(death,pos)
	death.z_index=3
	death.flip = flip
	death.anim = enemy
	Global.spawn_node(death,self)
