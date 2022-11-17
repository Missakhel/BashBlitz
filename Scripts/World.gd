extends Node

const BashBot = preload("res://Characters/BashBotR.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var num_players = 0;

var players = []

func isAnyoneNear(spawner):
	for i in players:
		if i.global_transform.origin.distance_to(spawner.global_transform.origin)<1:
			return true
	return false

func trySpawnAt(bot,spawner,name):
	if name == spawner.get_name():
		if isAnyoneNear(spawner):
			return false
		bot.global_transform.origin = spawner.global_transform.origin
		return true
	return false

func spawn(bot):
	var childs = get_children();
	for spawner in childs:
		if trySpawnAt(bot,spawner,"spawnPoint1"):
			return
		if trySpawnAt(bot,spawner,"spawnPoint2"):
			return
		if trySpawnAt(bot,spawner,"spawnPoint3"):
			return
		if trySpawnAt(bot,spawner,"spawnPoint4"):
			return
			
# Called when the node enters the scene tree for the first time.
func _ready():
	print("world")
	var conected = Input.get_connected_joypads()
	var childs = get_children();
	
	for i in range(len(conected)):
		var scoreBoard = get_node("/root/Arena/scoreBoard"+str(i))
		var bot = BashBot.instance()
		scoreBoard.visible = true
		scoreBoard.setPlayerName(str(i))
		
		bot.Id = i
		add_child(bot)
		players.append(bot)
		spawn(bot)

func respawn(Id):
	var bot = players[Id] as BashBot
	spawn(bot)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
	else:
		print("Keyboard")
