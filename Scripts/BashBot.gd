extends RigidBody

onready var spawnPoint = global_transform
onready var mesh = $MeshInstance
onready var cursor = $Cursor
onready var arrow = $MeshInstance/Arrow
onready var crashTexture = $MeshInstance/CrashTexture
onready var camera = get_node("/root/Arena/GlobalCamera")
onready var tuto = get_node("/root/Arena/TutorialHUD")
onready var sfx_clash = get_node("/root/Arena/SFX_Clash")
onready var sfx_fall = get_node("/root/Arena/SFX_Fall")
onready var sfx_respawn = get_node("/root/Arena/SFX_Respawn")
onready var isDashing = false

#Estas dos variables son necesarias para limitar la velocidad
export var acceleration = 75
export var topSpeed = 25

export var counterDamp = 1000
export var movementDamp = 7.5
export var dashImpulse = 216
export var dampMultiplier = 10
export var dashTime = 1.25
export var dashDamp = 15
export var axisDecceleration = 40
export var damp = 1.0/64.0

#Estas dos son necesarias para el impulso del dash con respecto al daño
export var damageResistance = 6.1
export var damagePercentage = 0
export var color : Color

#Declaración del producto punto, rotación global del mesh y el puntaje
var bashBotRotation : Vector3
var dotProduct : float
#export var score = 0

var canRespawn = false
var hasFallen = false
var softReset = false
var neuterX : bool
var neuterZ : bool

var cursorPosition = Vector3.ZERO
var dashCharge = 1
var dashPercentage = 0

func getMousePos():
	var playerPosition = global_transform.origin
	var camPosition = camera.get_camera_transform().origin
	var mouse_pos = get_viewport().get_mouse_position()
	return camera.project_position(mouse_pos,playerPosition.y-camPosition.y)
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	#Estas líneas son necesarias para cambiar el color de la flecha del robot
	var meshColor = SpatialMaterial.new()
	meshColor.albedo_color = color
	arrow.set_surface_material(0,meshColor)
	crashTexture.visible = false
	contact_monitor = true
	contacts_reported = 5
	arrow.set_scale(Vector3(1,.25,1))
	cursor.hide()

func chargingDash(_delta):
	isDashing = false
	#linear_damp = dashDamp
	if dashCharge <= dashTime:
		dashCharge += _delta
	dashPercentage = dashCharge / dashTime
	arrow.set_scale(Vector3(1,dashPercentage+.25,1))
	
func releaseDash(_delta):
	isDashing = true
	var playerPosition = global_transform.origin
	var mousePosition = -getMousePos()
	var direction = mousePosition -playerPosition
	direction = direction.normalized()
	
	linear_velocity = (direction*(dashPercentage*dashImpulse))
	#linear_damp = 1
	dashCharge = 0
	arrow.set_scale(Vector3(1,.25,1))
	
func moving(_delta):
	var vel = sqrt(linear_velocity.x*linear_velocity.x+linear_velocity.z*linear_velocity.z)
	if vel <= topSpeed:
		if Input.is_action_pressed("ui_left"):
			linear_velocity.x -= acceleration*_delta
			isDashing = false
		if Input.is_action_pressed("ui_right"):
			linear_velocity.x += acceleration*_delta
			isDashing = false
		if Input.is_action_pressed("ui_up"):
			linear_velocity.z -= acceleration*_delta
			isDashing = false
		if Input.is_action_pressed("ui_down"):
			linear_velocity.z += acceleration*_delta
			isDashing = false
			
func run(_delta):
	
	
	if Input.is_action_pressed("dash"):
		chargingDash(_delta)
	elif Input.is_action_just_released("dash"):
		releaseDash(_delta)
	else:
		moving(_delta)
		
	if Input.is_action_just_pressed("Reset"):
		tuto.visible = true
		softReset = true
	if Input.is_action_just_pressed("Enter"):
		tuto.visible = false
		
	#if hasFallen and scale > Vector3.ZERO:
	#	scale -= Vector3(1,1,1)*_delta
	#elif scale < Vector3.ZERO:
	#	canRespawn = true
	
	linear_velocity*=1.0-damp

func lookAtCursor(_delta):
	var playerPosition = global_transform.origin
	var cursorPosition = -getMousePos()
	var relapos = cursorPosition - playerPosition
	relapos *= 1000
	cursorPosition = relapos + playerPosition
	mesh.look_at(Vector3(cursorPosition.x,0,cursorPosition.z), Vector3.UP)

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

		if !isDashing and collisionBashbot.isDashing:#accumulatedForce > 7.5 and dotProduct < collisionBashbot.dotProduct:
			linear_damp = 1
			damagePercentage += accumulatedForce/damageResistance
			print(name," is ", damagePercentage, "% damaged")
			apply_central_impulse(facingDirection*(accumulatedForce/damageResistance)*(damagePercentage/damageResistance))
		elif isDashing:
			linear_damp = dashDamp
			crashTexture.visible = true
			sfx_clash.play()
			crashTexture.scale = Vector3.ZERO


func _on_Area_body_exited(body):
	if body.name == name:
		#print(body, " exited")
		#print(self.get_translation())
		sfx_fall.play()
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
		sfx_respawn.play()
		#print("Player 2 = ", Global.cscore)
		#print(self.get_translation())
	
	if softReset:
		softReset = false
		Global.cscore = 0
		#print("Player 2 = ",  Global.cscore)
		hasFallen = true
