extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var minDistance = 100
export var maxDistance = 200
export var multiplier = .2
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func dist2d(v):
	return v.x*v.x+v.z*v.z


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var w = get_node("/root/Arena/world")
	var pos = Vector3(0,0,0)
	for player in w.players:
		pos.x += player.transform.origin.x
		pos.z += player.transform.origin.z
	pos /= w.players.size()
	var farestDist = 0
	for player in w.players:
		var dist = dist2d(w.players[0].transform.origin-pos)
		if farestDist < dist:
			farestDist=dist
	if farestDist < minDistance:
		farestDist = minDistance
	if farestDist > maxDistance:
		farestDist = maxDistance
	transform.origin = Vector3(pos.x,farestDist*multiplier,pos.z)
	pass
