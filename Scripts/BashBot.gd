extends RigidBody

export var speed = 1.0
export var limit = 5
export var deacceleration = 5
var impulse = Vector3.ZERO

func _process(delta):
	if impulse.x < 0:
		impulse.x += delta*deacceleration
	elif impulse.x > 0:
		impulse.x -= delta*deacceleration
	if impulse.z < 0:
		impulse.z += delta*deacceleration
	elif impulse.z > 0:
		impulse.z -= delta*deacceleration

func _physics_process(delta):
	if Input.is_action_pressed("ui_left") and impulse.x > limit*-1:
		impulse.x -= speed
	if Input.is_action_pressed("ui_right") and impulse.x < limit:
		impulse.x += speed
	if Input.is_action_pressed("ui_up") and impulse.z > limit*-1:
		impulse.z -= speed
	if Input.is_action_pressed("ui_down") and impulse.z < limit:
		impulse.z += speed
	
	print(impulse)
	set_linear_velocity(impulse)
