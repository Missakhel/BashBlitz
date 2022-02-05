extends RigidBody

export var speed = 25
var rayOrigin = Vector3()
var rayEnd = Vector3()
onready var mesh = $MeshInstance
onready var camera = $Camera

func _process(_delta):
	if Input.is_action_pressed("ui_left"):
		linear_velocity.x -= speed*_delta
	if Input.is_action_pressed("ui_right"):
		linear_velocity.x += speed*_delta
	if Input.is_action_pressed("ui_up"):
		linear_velocity.z -= speed*_delta
	if Input.is_action_pressed("ui_down"):
		linear_velocity.z += speed*_delta

func _physics_process(_delta):
	#gettign the current phyisics state
	var space_state = get_world().direct_space_state
	#getting the current mouse position
	var mouse_position = get_viewport().get_mouse_position()

	rayOrigin = camera.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * 2000

	var intersection = space_state.intersect_ray(rayOrigin, rayEnd)

	if not intersection.empty():
		var pos = intersection.position
		mesh.look_at(Vector3(pos.x, 0, pos.z), Vector3(0,1,0))
		mesh.rotate_y(deg2rad(180))
		
	#apply_central_impulse(impulse)
	#print(impulse)
