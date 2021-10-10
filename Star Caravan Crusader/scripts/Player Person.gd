extends KinematicBody

export var speed = 14
export var gravity = 20
onready var cam = $Head/Camera
onready var head = $Head
onready var ground_check = $GroundCheck
onready var gun = $"Head/Gun/revolver-python"
onready var gun_lock = $Head/GunLock
onready var anim = $AnimationPlayer
onready var ammo = $"Control/ammo"
var full_contact = false
var mouse_sens = 0.3
var camera_anglev = 0
var h_accel = 6
var jump = 10
var SWAY = 3
var mouse_mov = Vector2()

var velocity = Vector3.ZERO
var h_vel = Vector3()
var movement = Vector3()
var grav_vec = Vector3()

export var sway_left : Vector3
export var sway_right : Vector3
export var sway_normal : Vector3
export var sway_value : int

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func set_camera_current(value):
	cam.current = value

func _process(delta):
	if mouse_mov.y > sway_value:
		gun.rotation = gun.rotation.linear_interpolate(Vector3(0, 0, sway_left.x), SWAY * delta)
	if mouse_mov.y < -sway_value:
		gun.rotation = gun.rotation.linear_interpolate(Vector3(0, 0, sway_right.x), SWAY * delta)
	if mouse_mov.x > sway_value:
		gun.rotation = gun.rotation.linear_interpolate(Vector3(0, sway_left.y, 0), SWAY * delta)
	elif mouse_mov.x < -sway_value:
		gun.rotation = gun.rotation.linear_interpolate(Vector3(0, sway_right.y, 0), SWAY * delta)
	else:
		gun.rotation = gun.rotation.linear_interpolate(sway_normal, SWAY * delta)

func _physics_process(delta):
	player_move(delta)

func player_move(delta):
	var direction = Vector3.ZERO
	full_contact = ground_check.is_colliding()

	if not is_on_floor():
		grav_vec += Vector3.DOWN * gravity * delta
	elif is_on_floor() and full_contact:
		grav_vec = -get_floor_normal() * gravity
	else:
		grav_vec = -get_floor_normal()

	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		grav_vec = Vector3.UP * jump

	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("run"):
		direction -= transform.basis.z
	
	direction = direction.normalized()
	h_vel = h_vel.linear_interpolate(direction * speed, h_accel * delta)
	movement.x = h_vel.x
	movement.z = h_vel.z
	movement.y = grav_vec.y
	velocity = move_and_slide(movement, Vector3.UP)


func _input(event):
	if event.is_action_pressed("shoot") and anim.get_current_animation() == "idle":
		var found_bullet = false
		for child in ammo.get_children():
			if child.visible:
				child.visible = false
				found_bullet = true
				break
		if found_bullet:
			anim.play("shoot")
		else:
			anim.play("refill")

	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		# Make weapon sway
		mouse_mov.x = - event.relative.x
		mouse_mov.y = - event.relative.y



func _on_animation_finished(anim_name):
	anim.play("idle")
