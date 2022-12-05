extends Control

#onready var text = get_node("GridContainer/Keyboard")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var score = 0

export var color : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	#text.text = "a"
	pass # Replace with function body.

func setPlayerName(name):
	var text = get_node("GridContainer/Keyboard")
	text.set_text("Score Player "+name + ":")#
	pass
	
func addPoint():
	score += 1
	var text = get_node("GridContainer/KScore")
	text.set_text(str(score))
	
func setDamagePercentage(p):
	var text = get_node("GridContainer3/KeyPercentage")
	text.set_text(str(p))
	if(p<100):
		text.modulate = lerp(Color.white,color,p/100)
	elif(p<200):
		text.modulate = lerp(color,Color.black,(p-100)/100)
	else:
		text.modulate = text.modulate
	#text.modulate =  Color.white * (1 - p/100)#Color.white-(Color.white-color)*p/100
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
