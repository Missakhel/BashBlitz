
extends Node
#var ASP = preload("res://Audio/AudioStreamPlayer.tscn")

export(Array, AudioStream) var audios

enum {ACTION_MISC_2, COLLECT_4, FLYING, LONG_SLIDE_DOWN, YOU_BEAST}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	makeSound(ACTION_MISC_2)
	pass # Replace with function body.

func makeSound(audio):
	var aud = AudioStreamPlayer.new()
	add_child(aud)
	aud.set_stream(audios[audio])
	aud.connect("finished",self,"onEnd")
	aud.play()
	
func makeSoundAtPlace(audio, position):
	var aud = AudioStreamPlayer3D.new()
	aud.transform.position = position
	add_child(aud)
	aud.set_stream(audios[audio])
	aud.connect("finished",self,"onEnd")
	aud.play()
	
func _process(delta):
	pass
	#makeSound(ACTION_MISC_2)
	
#	pass

func onEnd():
	var children = get_children()
	for child in children:
		if not child.is_playing():
			child.remove_and_skip()
			child.queue_free()
			print("deleted")
