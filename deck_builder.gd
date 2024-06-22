extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	DBM.start_level(1)
	update_btns()
	update_desc()
	
func update_btns():
	var btns = %Btns as Control
	for child in btns.get_children():
		btns.remove_child(child)
	for index in range(DBM.HandList.size()):
		var btn = Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_FILL
		btn.text = DBM.get_card_desc(index)
		btn.pressed.connect(_on_click.bind(index))
		btns.add_child(btn)
		
func update_desc():
	var cntInfo = DBM.CrntInfo
	(%Label as Label).text = "Current Level:{lvl} Element:{element}
	EnemyHp:{e_hp}
	PlayerHp:{p_hp},PlayerAttack:{p_atk}
	Point:{point}
	DeckNum:{deck}
	OffHandNum:{offhand}".format({
		"lvl":cntInfo["Level"]
		,"element":cntInfo["Element"]
		,"e_hp":cntInfo["Enemy"]["Hp"]
		,"p_hp":cntInfo["Self"]["Hp"]
		,"p_atk":cntInfo["Self"]["Atk"]
		,"point":cntInfo["Point"]
		,"deck":DBM.DeckCardList.size()
		,"offhand":DBM.OffHandList.size()})
	if cntInfo.has("NextLevel"):
		%Label.text = "\n Level Pass !!\n Click to Start Next Level:{0}\n".format([cntInfo["NextLevel"]])
	if cntInfo.has("Result"):
		if cntInfo["Result"] == DBM.WIN:
			%Label.text = "\n You Win !!! \n"
		else:
			%Label.text = "\n You Lose !!!\n"


func _on_click(index):
	var bSucc = DBM.select_card(index)
	if bSucc:
		update_btns()
		update_desc()


func _on_finish_pressed():
	if !DBM.CrntInfo.has("Result"):
		DBM.auto_fight()
	else:
		DBM.start_level(1)
	update_btns()
	update_desc()
	
