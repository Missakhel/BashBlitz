extends RigidBody

export var speed = 50
export var movementDamp = 2.5
export var dashImpulse = 25
export var dampMultiplier = 5
export var dashTime = 1.5
export var dashDamp = 5
export var damageResistance = .25
export var damagePercentage = 0

var cursorPosition = Vector3.ZERO
var dashCharge = 1
var dashPercentage = 0
var score = 0

onready var spawnPoint = get_transform()
onready var mesh = $MeshInstance
onready var cursor = $Cursor
onready var arrow = $MeshInstance/Arrow
onready var camera = get_node("/root/Arena/GlobalCamera")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	contact_monitor = true
	contacts_reported = 5
	arrow.set_scale(Vector3(1,.25,1))
	cursor.hide()

func run(_delta):
	if linear_damp < movementDamp:
		linear_damp += _delta*dampMultiplier

	if Input.is_action_pressed("dash"):
		linear_damp = dashDamp
		if dashCharge <= dashTime:
			dashCharge += _delta
		dashPercentage = dashCharge * 1 / dashTime
		arrow.set_scale(Vector3(1,dashPercentage+.25,1))
		
	if Input.is_action_just_released("dash"):
		linear_velocity = Vector3.ZERO
		var direction = cursor.global_transform.origin - global_transform.origin
		direction = direction.normalized()
		apply_central_impulse(direction*(dashPercentage*dashImpulse))
		linear_damp = -1
		dashCharge = 0
		arrow.set_scale(Vector3(1,.25,1))

	else:
		if Input.is_action_pressed("ui_left"):
			linear_velocity.x -= speed*_delta
			linear_damp = -1
		if Input.is_action_pressed("ui_right"):
			linear_velocity.x += speed*_delta
			linear_damp = -1
		if Input.is_action_pressed("ui_up"):
			linear_velocity.z -= speed*_delta
			linear_damp = -1
		if Input.is_action_pressed("ui_down"):
			linear_velocity.z += speed*_delta
			linear_damp = -1

func lookAtCursor(_delta):
	var playerPosition = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), playerPosition.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var rayLenght = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * rayLenght
	cursorPosition = dropPlane.intersects_ray(from,to)
	# Set the position of cursor visualizer
	cursorPosition = cursorPosition.normalized() * 2.5 + global_transform.origin
	cursor.global_transform.origin = cursorPosition - Vector3(0,-1,0)
	# Make player look at the cursor
	mesh.look_at(cursorPosition, Vector3.UP)

func _physics_process(_delta):
	run(_delta)
	lookAtCursor(_delta)

func _on_BashBot_collision(collisionBashbot):
	if collisionBashbot.name == "BashBotController":
		print("keyboard first")
		var accumulatedForce = 0
		if collisionBashbot.linear_velocity.x < 0:
			accumulatedForce += collisionBashbot.linear_velocity.x*-1
		else:
			accumulatedForce += collisionBashbot.linear_velocity.x
		if collisionBashbot.linear_velocity.z < 0:
			accumulatedForce += collisionBashbot.linear_velocity.z*-1
		else:
			accumulatedForce += collisionBashbot.linear_velocity.z
		accumulatedForce /= 2
		if accumulatedForce > 10:
			if linear_velocity < collisionBashbot.linear_velocity:
				damagePercentage += accumulatedForce * damageResistance
				print(collisionBashbot," is ", damagePercentage, "% damaged")
				apply_central_impulse(collisionBashbot.linear_velocity*-1*(damagePercentage/50))


func _on_Area_body_exited(body):
	print(body, " exited")
	print(global_transform.origin)
	set_transform(spawnPoint)
