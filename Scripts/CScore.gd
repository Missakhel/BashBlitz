extends Label

onready var bashbot = get_node("/root/Arena/BashBotController")

func _process(_delta):
	self.text = str(Global.cscore)
	modulate = bashbot.color