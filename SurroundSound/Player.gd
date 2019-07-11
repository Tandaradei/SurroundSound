extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper
var feet

var MOUSE_SENSITIVITY = 0.1
const STEP_DELAY = 0.5
var time_since_step = 0.0
var stepCount = 0

var simple_audio_player = preload("res://Simple_Audio_Player.tscn")

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	feet = $Feet_CollisionShape

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	time_since_step += delta
	if hvel.length() > 0.2 && time_since_step >= STEP_DELAY:
		for i in get_slide_count():
			var step_variance = Vector3()
			if stepCount % 2 == 0:
				step_variance = self.transform.basis.x * 40.0
			else:
				step_variance = self.transform.basis.x * -40.0
			var collision = get_slide_collision(i)
			if collision.collider_shape.get_meta("type") == "concrete":
				create_sound("footstep_concrete", self.global_transform.origin + step_variance)
				time_since_step = 0.0
				stepCount += 1
				break
			if collision.collider_shape.get_meta("type") == "wood":
				create_sound("footstep_wood", self.global_transform.origin + step_variance)
				time_since_step = 0.0
				stepCount += 1
				break

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
		
		
func create_sound(sound_name, position=null):
    var audio_clone = simple_audio_player.instance()
    var scene_root = get_tree().root.get_children()[0]
    scene_root.add_child(audio_clone)
    audio_clone.play_sound(sound_name, position)