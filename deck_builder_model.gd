extends Node

#region 常量配置
const DECK_CARD_NUM=5
const BASE_POINT_NUM=5
const LEVEL_NUM=5
const WIN = 1
const FAIL = 0
#endregion

# 卡牌元数据
static var MetaCardList:Dictionary={}
# 卡组信息
static var DeckCardList:Array=[]
# 关卡信息
static var LevelInfo:Array=[]

# 手牌
static var HandList:Array=[]
static var OffHandList:Array=[]
	
# 初始属性
var InitShipInfo:={
	"Hp"=8,
	"Atk"=8
}
# 当前属性
var CrntInfo:={"Self":{},"Enemy":{}} # {Self={Hp,Atk},Enemy={Hp,Atk},Level,Element,Point,Result,NextLevel}


func _init():
	MetaCardList.clear()
	MetaCardList["hp-1-1"]={"Cost":1,"Hp":1,"Draw":0}
	MetaCardList["hp-1-2"]={"Cost":1,"Hp":2,"Draw":0}
	MetaCardList["hp-2-3"]={"Cost":2,"Hp":3,"Draw":1}
	#MetaCardList["hp-2-4"]={"Cost":2,"Hp":4,"Draw":0}
	MetaCardList["hp-3-5"]={"Cost":3,"Hp":5,"Draw":0}
	MetaCardList["atk-1-1"]={"Cost":1,"Atk":1,"Draw":1}
	MetaCardList["atk-1-2"]={"Cost":1,"Atk":2,"Draw":0}
	#MetaCardList["atk-2-3"]={"Cost":2,"Atk":3,"Draw":0}
	MetaCardList["atk-2-4"]={"Cost":2,"Atk":4,"Hp":1,"Draw":0}
	MetaCardList["atk-3-5"]={"Cost":3,"Atk":5,"Draw":0}
	# 2种属性，
	DeckCardList.clear()
	var baseList = [["1-1","1-2","2-3","2-3","3-5"] # 8张牌
	,["1-1","1-2","2-4","2-4","3-5"]] # 8张牌
	var repairType = ["hp-","atk-"] # 2种修复
	var elementType = ["Wind","Fire"] # 2种属性
	for element in elementType:
		var idx = 0
		for repair in repairType:
			for base in baseList[idx]:
				DeckCardList.append({"Element":element,"Id":repair+base})
			idx += 1
	# 关卡信息
	LevelInfo.clear()
	var baseAtk = 10
	var baseHp = 10
	# 5个关卡
	for i in range(LEVEL_NUM): 
		LevelInfo.append({"Atk":baseAtk+i,"Hp":baseHp+i*2})
	
#region 流程
func start_level(level):
	CrntInfo.clear()
	CrntInfo["Self"]={}
	CrntInfo["Enemy"]={}
	CrntInfo.get("Self")["Hp"]=InitShipInfo.get("Hp")
	CrntInfo.get("Self")["Atk"]=InitShipInfo.get("Atk")
	CrntInfo.get("Enemy")["Hp"]=LevelInfo[level].get("Hp")
	CrntInfo.get("Enemy")["Atk"]=LevelInfo[level].get("Atk")
	CrntInfo["Element"] = "Fire" if randf()<0.5 else "Wind"
	CrntInfo["Level"] = level
	CrntInfo["Point"] = BASE_POINT_NUM
	auto_fight()
	pass
func draw_hand_cards(num,bClear=true):
	if bClear:
		for card in HandList:
			OffHandList.append(card)
		HandList.clear()
		CrntInfo["Point"]=BASE_POINT_NUM
	if DeckCardList.size() < num:
		for card in OffHandList:
			DeckCardList.append(card)
		OffHandList.clear()
	DeckCardList.shuffle()
	for i in range(num):
		var card = DeckCardList.pop_back()
		HandList.append(card)
	prints("draw_hand_cards",OffHandList,HandList,DeckCardList.size())
func auto_fight():
	var nextlvl = CrntInfo.get("NextLevel")
	if nextlvl:
		CrntInfo["NextLevel"]=null
		start_level(nextlvl)
		return
	# 玩家打怪
	var atkp = CrntInfo["Self"]["Atk"]
	var hpp = CrntInfo["Self"]["Hp"]
	var atke = CrntInfo["Enemy"]["Atk"]
	var hpe = CrntInfo["Enemy"]["Hp"]
	for i in range(atkp):
		if randf() < 0.8:
			hpe -= 1
	CrntInfo["Enemy"]["Hp"] = max(0,hpe)
	# 怪打玩家
	var dmg = 0
	for i in range(atke):
		if randf() < 0.9:
			dmg+=1
	var diff = dmg
	var hpDmg = 0
	var atkDmg = 0
	while diff > 3:
		hpDmg = randi_range(0,dmg)
		atkDmg = dmg - hpDmg
		diff = abs(atkDmg-hpDmg)
	CrntInfo["Self"]["Atk"] = max(0,atkp-atkDmg)
	CrntInfo["Self"]["Hp"] = max(0,hpp-hpDmg)
	
	if CrntInfo["Enemy"]["Hp"] <= 0:
		game_win()
	elif CrntInfo["Self"]["Hp"] <= 0:
		game_fail()
	else :
		draw_hand_cards(DECK_CARD_NUM)
	pass
func game_fail():
	CrntInfo["Result"]=FAIL
	pass

func game_win():
	var lvl = CrntInfo["Level"]
	if lvl >= LEVEL_NUM:
		prints("You Win !!")
		CrntInfo["Result"]=WIN
		return
	CrntInfo["NextLevel"]=lvl+1
#endregion

#region 玩家操作

# 使用卡牌，失败返回false
func get_card_desc(index):
	var tbl = HandList[index]
	var element = tbl["Element"]
	var id = tbl["Id"]
	var cardInfo = MetaCardList.get(id)
	var atk = cardInfo.get("Atk",0)
	var hp = cardInfo.get("Hp",0)
	var cost = cardInfo["Cost"]
	var draw = cardInfo["Draw"]
	
	if CrntInfo["Element"] != element:
		cost = max(1,cost+1)
	return "Cost:{0}  {1} 
Atk:{2}
Hp:{3}
Draw:{4}".format([cost,element,atk,hp,draw])
func select_card(index):
	var card = HandList[index]
	var element = card["Element"]
	var id = card["Id"]
	var cardInfo = MetaCardList.get(id) as Dictionary
	var atk = cardInfo.get("Atk",0)
	var hp = cardInfo.get("Hp",0)
	var cost = cardInfo["Cost"]
	var draw = cardInfo["Draw"]
	if CrntInfo["Element"] != element:
		cost = max(1,cost+1)
	if CrntInfo["Point"] < cost:
		return false # 点数不够
	CrntInfo["Point"] -= cost
	if atk > 0:
		var old = CrntInfo["Self"]["Atk"]
		CrntInfo["Self"]["Atk"] = min(InitShipInfo["Atk"],CrntInfo["Self"]["Atk"]+atk)
		prints("[Add Attack] from {0} to {1}".format([old,CrntInfo["Self"]["Atk"]]))
	if hp > 0:
		var old = CrntInfo["Self"]["Hp"]
		CrntInfo["Self"]["Hp"] = min(InitShipInfo["Hp"],CrntInfo["Self"]["Hp"]+hp)
		prints("[Add Hp] from {0} to {1}".format([old,CrntInfo["Self"]["Hp"]]))
	if draw > 0:
		draw_card(draw)
	HandList.remove_at(index)
	OffHandList.append(card)
	
	return true

func draw_card(num):
	draw_hand_cards(num,false)
#endregion
