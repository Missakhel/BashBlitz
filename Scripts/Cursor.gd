extends MeshInstance

onready var bot = get_parent()

func _ready():
	pass

func _physics_process(delta):
	var botPosition = bot.global_transform.origin
	look_at(botPosition, Vector3.UP)
	rotation.x = 90
