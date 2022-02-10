extends KinematicBody

export var speed = 150
export var friction = 0.875
export var gravity = 80

var move_direction = Vector3()
var vel = Vector3()

onready var camera = $Camera
onready var cursor= $Cursor

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	look_at_cursor()
	run(delta)
	
	vel *= friction
	vel.y -= gravity*delta
	vel = move_and_slide(vel, Vector3.UP, true, 3)

func camera_follows_player():
	var playerPosition = global_transform.origin

func look_at_cursor():
	# Create a horizontal plane, and find a point where the ray intersects with it
	var playerPosition = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), playerPosition.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var rayLenght = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * rayLenght
	var cursor_pos = dropPlane.intersects_ray(from,to)
	
	# Set the position of cursor visualizer
	cursor.global_transform.origin = cursor_pos - Vector3(0,1,0)
	
	# Make player look at the cursor
	look_at(cursor_pos, Vector3.UP)
	remove_child(cursor)


func run(delta):
	move_direction = Vector3()
	var camera_basis = camera.get_global_transform().basis
	if Input.is_action_pressed("ui_down"):
		move_direction -= camera_basis.z
	elif Input.is_action_pressed("ui_up"):
		move_direction += camera_basis.z
	if Input.is_action_pressed("ui_right"):
		move_direction -= camera_basis.x
	elif Input.is_action_pressed("ui_left"):
		move_direction += camera_basis.x
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	vel += move_direction*speed*delta
