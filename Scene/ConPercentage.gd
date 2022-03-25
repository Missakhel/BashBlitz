extends Label


func _process(delta):
	self.text = str(stepify(Global.cdamage, 0.1))