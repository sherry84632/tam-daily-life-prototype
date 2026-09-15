extends StaticBody3D

var can_place = false
var has_placed = false
var npc = null
var dialogue_ui = null

func _ready():
	var root = get_tree().root
	var map = root.get_node_or_null("Map")
	if map:
		if map.has_node("NPC"):
			npc = map.get_node("NPC")
		if map.has_node("DialogueUI"):
			dialogue_ui = map.get_node("DialogueUI")

func interact(player):
	if has_placed:
		return
		
	if can_place:
		var tep_amount = player.inventory.get("tep", 0)
		player.add_item("tep", -tep_amount)
		
		if has_node("BasketMesh"):
			$BasketMesh.visible = true
			
		has_placed = true
		
		if npc:
			npc.steal_basket(self)
	else:
		if dialogue_ui:
			dialogue_ui.start_dialogue(["Cái bàn này để đặt giỏ tép."], "Hệ thống", player)
