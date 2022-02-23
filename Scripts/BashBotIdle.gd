extends KinematicBody

export var speed = 150
export var friction = 0.875
export var counterweight = 1.5
var counterimpulse = 0

var move_direction = Vector3()
var vel = Vector3()
var collidingDir = Vector3()

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
	run(delta)
	if collidingDir != Vector3.ZERO:
		vel += collidingDir * counterimpulse * counterweight
	vel *= friction
	vel = move_and_slide(vel, Vector3.UP, false, 3, 0.0, true)

func run(delta):
	if get_slide_collision(0) != null:
		collidingDir = get_slide_collision(0).normal
		counterimpulse = (get_slide_collision(0).collider_velocity.x + get_slide_collision(0).collider_velocity.z)/2
		if counterimpulse < 0:
			counterimpulse *= -1
		print("impulse: ",counterimpulse," | normal: ",collidingDir)
	else:
		collidingDir = Vector3.ZERO