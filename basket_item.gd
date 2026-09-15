extends StaticBody3D

func interact(player):
	if player.has_method("equip_basket"):
		player.equip_basket()
		queue_free()
