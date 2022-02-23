extends KinematicBody

export var speed = 150
export var friction = 0.875
export var extraVelMulti = 5000

var move_direction = Vector3()
var vel = Vector3()

var cursor_pos_global = Vector3.ZERO

onready var cursor= $Cursor
onready var globalCamera = get_node("/root/Arena/GlobalCamera")
onready var camera = $Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	look_at_cursor(delta)
	run(delta)
	vel *= friction
	vel = move_and_slide(vel, Vector3.UP, false, 3, 0.0, true)
	
func camera_follows_player():
	var playerPosition = global_transform.origin

func look_at_cursor(delta):
	# Create a horizontal plane, and find a point where the ray intersects with it
	var playerPosition = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), playerPosition.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var rayLenght = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = globalCamera.project_ray_origin(mouse_pos)
	var to = from + globalCamera.project_ray_normal(mouse_pos) * rayLenght
	var cursor_pos = dropPlane.intersects_ray(from,to)
	# Set the position of cursor visualizer
	cursor.global_transform.origin = cursor_pos - Vector3(0,-1,0)
	cursor_pos_global = cursor_pos
	# Make player look at the cursor
	look_at(cursor_pos, Vector3.UP)

func run(delta):
	move_direction = Vector3()
	if Input.is_action_just_pressed("dash"):
		var direction = cursor_pos_global - get_global_transform().origin
		direction = direction.normalized()
		vel+=direction*extraVelMulti*delta
	else:
		if Input.is_action_pressed("ui_down"):
			vel.z+=speed*delta
		elif Input.is_action_pressed("ui_up"):
			vel.z-=speed*delta
		if Input.is_action_pressed("ui_right"):
			vel.x+=speed*delta
		elif Input.is_action_pressed("ui_left"):
			vel.x-=speed*delta
	move_direction.y = 0
	move_direction = move_direction.normalized()
	vel += move_direction*speed*delta
