extends Label


func _process(delta):
	self.text = str(stepify(Global.kdamage, 0.1))