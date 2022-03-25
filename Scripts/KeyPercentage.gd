extends Label

onready var bashbot = get_node("/root/Arena/BashBotKeyboard")

func _process(_delta):
	self.text = str(stepify(Global.kdamage, 0.1))
	modulate = bashbot.color