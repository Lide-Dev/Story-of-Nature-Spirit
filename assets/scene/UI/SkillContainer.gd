extends Control

enum{
	IDLE,
	ENTERED
}
var state = IDLE
var skillbutton = []
var pressedbtn
var world
var muchLearned = 0

onready var statContainer = $StatSkill/Container/SkillStatContainer
onready var pointName = $StatSkill/Container/SkillPoint/Value
onready var skillName = $StatSkill/Container/SkillStatContainer/VBoxContainer/SkillName/Value
onready var levelName = $StatSkill/Container/SkillStatContainer/VBoxContainer/Level/Value
onready var typeName = $StatSkill/Container/SkillStatContainer/VBoxContainer/Type/Value
onready var toggleContainer = $StatSkill/Container/SkillStatContainer/VBoxContainer/Toggle
onready var toggleText = $StatSkill/Container/SkillStatContainer/VBoxContainer/Toggle/Value

onready var learnedContainer = $StatSkill/Container/SkillLearnedContainer
onready var skillLearnedBox = $StatSkill/Container/SkillLearnedContainer/ScrollContainer/SkillLearned
onready var textDummy = $StatSkill/Container/SkillLearnedContainer/ScrollContainer/SkillLearned/Skill1

onready var welcomContainer = $InfoSkill/Container/Welcome

onready var descContainer = $InfoSkill/Container/SkillDescContainer
onready var requireText = $InfoSkill/Container/SkillDescContainer/Require/Value
onready var costText= $InfoSkill/Container/SkillDescContainer/Cost/Value
onready var descText = $InfoSkill/Container/SkillDescContainer/DescValue

onready var btnContainer = $ButtonSkill
onready var learnBtn = $ButtonSkill/Learn
onready var toggleBtn = $ButtonSkill/Toggle

func _ready():
	var node = get_tree().get_nodes_in_group("World")
	world = node[0]
	$AnimationPlayer.play("IdleSkill")
	pointName.text= str(world.skill_point)
	for i in range($CharButtonContainer.get_child_count()):
		node = $CharButtonContainer.get_child(i)
		var skill = DataImport.skill_data[node.name]
		var currentskill = world.get_skilltree(node.name)
		skillbutton.push_back(node)
		node.mouse_filter = Control.MOUSE_FILTER_PASS
		node.connect("toggled",self,"_on_ClickSkillBtn",[$CharButtonContainer.get_child(i)])
		
		var k = skill.lvl+(skill.lvlup*currentskill.lvl)
		if currentskill.lvl > 0:
			node.set("custom_styles/normal",load("res://assets/img/UI/btn-skill-learned.tres"))
			if muchLearned > 0:
				var new=textDummy.duplicate(8)
				new.text = skill.name + " Lv."+ str(currentskill.lvl)
				skillLearnedBox.add_child(new)
			else:
				textDummy.text = skill.name + " Lv."+ str(currentskill.lvl)
			muchLearned +=1
		if world.level < int(k):
			node.set("custom_styles/normal",load("res://assets/img/UI/btn-skill-lvlless.tres"))

func update_learned():
	muchLearned = 0
	for a in range(skillLearnedBox.get_child_count()):
		var current = skillLearnedBox.get_child(a)
		if current.name != "Skill1":
			current.queue_free()
	for node in skillbutton:
		var skill = DataImport.skill_data[node.name]
		var currentskill = world.get_skilltree(node.name)
		if currentskill.lvl >0:
			if muchLearned > 0:
				var new=textDummy.duplicate(8)
				new.text = skill.name + " Lv."+ str(currentskill.lvl)
				skillLearnedBox.add_child(new)
			else:
				textDummy.text = skill.name + " Lv."+ str(currentskill.lvl)
			muchLearned +=1

func update_text():
	var skill = DataImport.skill_data[pressedbtn.name]
	var currentskill = world.get_skilltree(pressedbtn.name)
	skillName.text=skill.name
	if (currentskill.lvl ==5 ):
		levelName.text="5 (Max Level)"
	else:
		levelName.text=str(currentskill.lvl)
	typeName.text=skill.type
	requireText.text = str(skill.lvl+(skill.lvlup*world.get_skilltree(pressedbtn.name,"lvl")))
	descText.text = skill.desc
	if (skill.type == "Toggle" && currentskill.lvl > 0):
		toggleBtn.disabled = false
		toggleContainer.show()
		toggleText.text = str(currentskill.toggled)
	else:
		toggleBtn.disabled = true
		toggleContainer.hide()

func update_nodeskill():
	var skill = DataImport.skill_data[pressedbtn.name]
	var currentskill = world.get_skilltree(pressedbtn.name)
	
	if is_instance_valid(pressedbtn):
		var k = skill.lvl+(skill.lvlup*currentskill.lvl)
		if world.level < int(k):
			pressedbtn.set("custom_styles/normal",load("res://assets/img/UI/btn-skill-lvlless.tres"))
		elif currentskill.lvl > 0:
			pressedbtn.set("custom_styles/normal",load("res://assets/img/UI/btn-skill-learned.tres"))
	
	if (world.level >= (skill.lvl+(currentskill.lvl*skill.lvlup)) and currentskill.lvl < 5):
		learnBtn.disabled = false
	else:
		learnBtn.disabled = true

func _on_Char_mouse_entered():
	$AnimationPlayer.play("EnterSkill")

func _on_Char_mouse_exited():
	$AnimationPlayer.play("IdleSkill")

func _on_ClickSkillBtn(btn_pressed,btn):
	if is_instance_valid(pressedbtn):
		if pressedbtn != btn:
			pressedbtn.pressed = false
	pressedbtn = btn
	if btn_pressed:
		var skill = DataImport.skill_data[pressedbtn.name]
		var currentskill = world.get_skilltree(pressedbtn.name)
		update_text()
		statContainer.show()
		descContainer.show()
		btnContainer.show()
		welcomContainer.hide()
		learnedContainer.hide()
		
		if (world.level >= (skill.lvl+(currentskill.lvl*skill.lvlup))  and currentskill.lvl < 5):
			learnBtn.disabled = false
		else:
			learnBtn.disabled = true
			
	else:
		statContainer.hide()
		descContainer.hide()
		btnContainer.hide()
		welcomContainer.show()
		learnedContainer.show()

func _on_Learn_pressed():
	if (world.skill_point > 0):
		var skill = DataImport.skill_data[pressedbtn.name]
		var currentskill = world.get_skilltree(pressedbtn.name)
		if world.level >= (skill.lvl+(currentskill.lvl*skill.lvlup)):
			if (currentskill.lvl == 0):
				Global.create_alert("You have learned "+skill.name+" skill!")
				if skill.type == "Toggle":
					world.set_skilltree(pressedbtn.name,"toggled",true)
			else:
				Global.create_alert("You have level up "+skill.name+" skill to level "+ str(currentskill.lvl+1) +"!")
			world.set_skilltree(pressedbtn.name,"lvl",currentskill.lvl+1)
			world.skill_point -= 1
			update_text()
			update_nodeskill()
			update_learned()
		else:
			Global.create_alert("Your level is not enough to learn this skill!")
	else:
		Global.create_alert("Your skill point is not enough to spend at this skill!")

func _on_Toggle_pressed():
	world.set_skilltree(pressedbtn.name,"toggled",!world.get_skilltree(pressedbtn.name,"toggled"))
	update_text()
