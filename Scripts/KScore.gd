extends Label

onready var bashbot = get_node("/root/Arena/BashBotKeyboard")

func _process(_delta):
	self.text = str(Global.kscore)
	modulate = bashbot.color