extends CanvasLayer

@onready var tep_label = $Control/Panel/TepLabel

func update_tep_count(amount):
	if tep_label == null:
		tep_label = $Control/Panel/TepLabel
	if tep_label:
		tep_label.text = "Giỏ Tép: " + str(amount)
