extends CharacterBody2D

const SPEED = 300
const JUMP_VELOCITY = -400
const GRAVITY = 900
const FLOOR_NORMAL = Vector2.UP
const MAX_FALL_SPEED = 900
const ACCELERATION = 800
const FRICTION = 600

@export var dash_speed := 600
@export var dash_duration := 0.2
@export var dash_cooldown := 1.5

var can_double_jump := true
var can_dash := true
var is_dashing := false

func _physics_process(delta: float) -> void:
	
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var current_speed = dash_speed if is_dashing else SPEED
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		can_double_jump = true
		velocity.y = 0
		
	if input_vector.x != 0:
		velocity.x = move_toward(velocity.x, input_vector.x * current_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	# Jumping
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Double jump
	if Input.is_action_just_pressed("ui_up") and not is_on_floor() and velocity.y > 0 and can_double_jump:
		can_double_jump = false
		velocity.y = JUMP_VELOCITY

	# Dashing
	if Input.is_action_just_pressed("dash") and can_dash and input_vector.length() > 0:
		start_dash()

	move_and_slide()

func start_dash():
	is_dashing = true
	can_dash = false

	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
