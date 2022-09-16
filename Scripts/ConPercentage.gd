extends Label

onready var bashbot = get_node("/root/Arena/BashBotController")

func _process(_delta):
	self.text = str(stepify((Global.cdamage*2.5), 0.1))
	modulate = bashbot.color
