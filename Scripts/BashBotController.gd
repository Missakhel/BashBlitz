extends RigidBody

export var speed = 50
export var movementDamp = 2.5
export var dashImpulse = 25
export var dampMultiplier = 5
export var dashTime = 1.5
export var dashDamp = 5
export var damageResistance = .25
export var damagePercentage = 0

onready var mesh = $MeshInstance
onready var cursor = $Cursor
onready var arrow = $MeshInstance/Arrow
onready var camera = get_node("/root/Arena/GlobalCamera")

var dashCharge = 1
var dashPercentage = 0
var cursorPosition = Vector3.ZERO
var score = 0

func _ready():
	contact_monitor = true
	contacts_reported = 5
	arrow.set_scale(Vector3(1,.25,1))
	cursor.hide()

func run(_delta):
	if linear_damp < movementDamp:
		linear_damp += _delta*dampMultiplier

	if Input.is_action_pressed("pad_dash"):
		linear_damp = dashDamp
		if dashCharge <= dashTime:
			dashCharge += _delta
		dashPercentage = dashCharge * 1 / dashTime
		arrow.set_scale(Vector3(1,dashPercentage+.25,1))
		
	if Input.is_action_just_released("pad_dash"):
		linear_velocity = Vector3.ZERO
		var direction = cursor.global_transform.origin - global_transform.origin
		direction = direction.normalized()
		apply_central_impulse(direction*(dashPercentage*dashImpulse))
		linear_damp = -1
		dashCharge = 0
		arrow.set_scale(Vector3(1,.25,1))

	else:
		if Input.get_action_strength("stick_left")>0:
			linear_velocity.x -= speed*_delta
			linear_damp = -1
		if Input.get_action_strength("stick_right")>0:
			linear_velocity.x += speed*_delta
			linear_damp = -1
		if Input.get_action_strength("stick_up")>0:
			linear_velocity.z -= speed*_delta
			linear_damp = -1
		if Input.get_action_strength("stick_down")>0:
			linear_velocity.z += speed*_delta
			linear_damp = -1

		if Input.get_action_strength("aim_left")>0:
			cursorPosition.x -= Input.get_action_strength("aim_left")			
		if Input.get_action_strength("aim_right")>0:
			cursorPosition.x += Input.get_action_strength("aim_right")
		if Input.get_action_strength("aim_up")>0:
			cursorPosition.z -= Input.get_action_strength("aim_up")
		if Input.get_action_strength("aim_down")>0:
			cursorPosition.z += Input.get_action_strength("aim_down")
		if cursorPosition != Vector3.ZERO:
			cursorPosition = cursorPosition.normalized()
			cursor.global_transform.origin = cursorPosition * 2.5 + global_transform.origin

	mesh.look_at(cursor.global_transform.origin, Vector3.UP)

func _physics_process(_delta):
	run(_delta)

func _on_BashBot_collision(collisionBashbot):
	if collisionBashbot.name == "BashBotKeyboard":
		print("controller first")
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
