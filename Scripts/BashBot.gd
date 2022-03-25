extends RigidBody

#Estas dos variables son necesarias para limitar la velocidad
export var acceleration = 50
export var topSpeed = 25

export var movementDamp = 2.5
export var dashImpulse = 25
export var dampMultiplier = 5
export var dashTime = 1.5
export var dashDamp = 5

#Estas dos son necesarias para el impulso del dash con respecto al daño
export var damageResistance = .25
export var damagePercentage = 0
export var color : Color


#Declaración del producto punto, rotación global del mesh y el puntaje
var bashBotRotation : Vector3
var dotProduct : float
#export var score = 0

var canRespawn = false
var hasFallen = false
var softReset = false

var cursorPosition = Vector3.ZERO
var dashCharge = 1
var dashPercentage = 0

onready var spawnPoint = global_transform
onready var mesh = $MeshInstance
onready var cursor = $Cursor
onready var arrow = $MeshInstance/Arrow
onready var camera = get_node("/root/Arena/GlobalCamera")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	#Estas líneas son necesarias para cambiar el color de la flecha del robot
	var meshColor = SpatialMaterial.new()
	meshColor.albedo_color = color
	arrow.set_surface_material(0,meshColor)

	contact_monitor = true
	contacts_reported = 5
	arrow.set_scale(Vector3(1,.25,1))
	cursor.hide()
	

func run(_delta):
	Global.kdamage = damagePercentage

	if linear_damp < movementDamp:
		linear_damp += _delta*dampMultiplier

	if Input.is_action_pressed("dash"):
		linear_damp = dashDamp
		if dashCharge <= dashTime:
			dashCharge += _delta
		dashPercentage = dashCharge * 1 / dashTime
		arrow.set_scale(Vector3(1,dashPercentage+.25,1))
		
	elif Input.is_action_just_released("dash"):
		linear_velocity = Vector3.ZERO
		var direction = cursor.global_transform.origin - global_transform.origin
		direction = direction.normalized()
		apply_central_impulse(direction*(dashPercentage*dashImpulse))
		linear_damp = 1
		dashCharge = 0
		arrow.set_scale(Vector3(1,.25,1))

	else:
		#Estos son los nuevos parámetros para acceder a la función y limitan la velocidad
		if Input.is_action_pressed("ui_left") and linear_velocity.x >= topSpeed*-1:
			linear_velocity.x -= acceleration*_delta
			linear_damp = -1
		if Input.is_action_pressed("ui_right") and linear_velocity.x <= topSpeed:
			linear_velocity.x += acceleration*_delta
			linear_damp = -1
		if Input.is_action_pressed("ui_up") and linear_velocity.z >= topSpeed*-1:
			linear_velocity.z -= acceleration*_delta
			linear_damp = -1
		if Input.is_action_pressed("ui_down") and linear_velocity.z <= topSpeed:
			linear_velocity.z += acceleration*_delta
			linear_damp = -1
		
		#Botón de Reseteado
		if Input.is_action_just_pressed("Reset"):
			softReset = true

	#Esta línea de abajo se usa para obtener el producto punto
	bashBotRotation = mesh.rotation_degrees - rotation_degrees + Vector3(0,90,0)

	#Condicional de caída
	if hasFallen and scale > Vector3.ZERO:
		scale -= Vector3(1,1,1)*_delta
	elif scale < Vector3.ZERO:
		canRespawn = true
		

	
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

		var facingDirection = collisionBashbot.mesh.global_transform.origin.direction_to(mesh.global_transform.origin)
		dotProduct = facingDirection.dot(collisionBashbot.bashBotRotation)

		if accumulatedForce > 10 and dotProduct < collisionBashbot.dotProduct:
			damagePercentage += accumulatedForce * damageResistance
			print(name," is ", damagePercentage, "% damaged")
			apply_central_impulse(facingDirection*(accumulatedForce/10)*(damagePercentage/10))
		else:
			linear_damp = dashDamp


func _on_Area_body_exited(body):
	if body.name == name:
		#print(body, " exited")
		#print(self.get_translation())
		hasFallen = true
		Global.cscore += 1
		
		

func _integrate_forces(state):
	if canRespawn: 
		canRespawn = false
		hasFallen = false
		linear_velocity.x = 0
		linear_velocity.z = 0
		damagePercentage = 0
		state.set_transform(spawnPoint)
		print("Player 2 = ",  Global.cscore)
		#print(self.get_translation())
	
	if softReset:
		softReset = false
		Global.cscore = 0
		
		print("Player 2 = ",  Global.cscore)
		hasFallen = true
