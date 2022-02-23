extends RigidBody

export var speed = 25
export var dashImpulse = 25
var cursor_pos_global = Vector3.ZERO
onready var mesh = $MeshInstance
onready var cursor = $Cursor
onready var camera = get_node("/root/Arena/GlobalCamera")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func run(_delta):
	if Input.is_action_just_pressed("dash"):
		linear_velocity = Vector3.ZERO
		var direction = cursor_pos_global - get_global_transform().origin
		direction = direction.normalized()
		apply_central_impulse(direction*dashImpulse)
	else:
		if Input.is_action_pressed("ui_left"):
			linear_velocity.x -= speed*_delta
		if Input.is_action_pressed("ui_right"):
			linear_velocity.x += speed*_delta
		if Input.is_action_pressed("ui_up"):
			linear_velocity.z -= speed*_delta
		if Input.is_action_pressed("ui_down"):
			linear_velocity.z += speed*_delta

func lookAtCursor(_delta):
	var playerPosition = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), playerPosition.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var rayLenght = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * rayLenght
	var cursor_pos = dropPlane.intersects_ray(from,to)
	# Set the position of cursor visualizer
	cursor.global_transform.origin = cursor_pos - Vector3(0,-1,0)
	cursor_pos_global = cursor_pos
	# Make player look at the cursor
	mesh.look_at(cursor_pos, Vector3.UP)

func _physics_process(_delta):
	run(_delta)
	lookAtCursor(_delta)
