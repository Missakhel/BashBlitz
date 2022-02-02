extends RigidBody

export var speed = 30

func _process(_delta):
	pass

func _physics_process(_delta):
	if Input.is_action_pressed("ui_left"):
		linear_velocity.x -= speed*_delta
	if Input.is_action_pressed("ui_right"):
		linear_velocity.x += speed*_delta
	if Input.is_action_pressed("ui_up"):
		linear_velocity.z -= speed*_delta
	if Input.is_action_pressed("ui_down"):
		linear_velocity.z += speed*_delta
	
	#apply_central_impulse(impulse)
	#print(impulse)
