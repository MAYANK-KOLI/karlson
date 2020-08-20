extends KinematicBody


var speed = 10
var acceleration = 10
var gravity = 0.2
var jump = 15
var can_slide = false
var mouse_sensitivity = 0.2
var damage = 50
var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()
onready var head = $Head

onready var aimcast =  $Head/Camera/Aimcast
onready var Camera = $Head/Camera
onready var ap = $Head/Camera/AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func wall_run():
	if Input.is_action_pressed("front"):
		if Input.is_action_pressed("jump"):
			if is_on_wall():
				fall.y = 0
				ap.play("Wallrunning")

func _physics_process(delta):
	direction = Vector3()
	move_and_slide(fall, Vector3.UP)
	
	if Input.is_action_just_pressed("fire"):
		ap.play("shoot")
		if aimcast.is_colliding():
			if is_in_group("Target"):
				queue_free()
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("lock"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not is_on_floor():
		fall.y -= gravity
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump
	wall_run()

	if Input.is_action_just_pressed("slow"):
		Engine.time_scale = 0.2
		
		gravity = 0.04
	if Input.is_action_just_released("slow"):
		Engine.time_scale = 1
		gravity = 0.2
	if Input.is_action_pressed("slide"):
		speed = 26
		self.scale=Vector3(0.5,0.5,0.5)
		

	if Input.is_action_just_released("slide"):
		can_slide = true
		speed = 10
		self.scale=Vector3(1,1,1)
	if Input.is_action_pressed("front"):
		ap.play("bobbing")
		
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("back"):
		ap.play("bobbing")
		direction += transform.basis.z
		
	if Input.is_action_pressed("left"):
		
		direction -= transform.basis.x			
		
	elif Input.is_action_pressed("right"):
		
		direction += transform.basis.x
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
	velocity = move_and_slide(velocity, Vector3.UP)




	




func _on_Area2_area_entered(area):
	if area.is_in_group("jumpad"):
		jump = 30


func _on_Area2_area_exited(area):
	if area.is_in_group("jumpad"):
		jump = 15
