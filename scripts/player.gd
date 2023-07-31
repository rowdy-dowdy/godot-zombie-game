extends CharacterBody3D

@onready var animation_tree = $visuals/woman1/AnimationTree
@onready var camera_mount = $camera_mount
@onready var visuals = $visuals

var SPEED = 1
const JUMP_VELOCITY = 4.5
const HIT_STAGGER = 8

var walking_speed = 1
var running_speed = 3

var running = false

var is_locked = false

# singal
signal player_hit

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
#		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _physics_process(delta):
	if !animation_tree.get("parameters/hit_tr2/active") and !animation_tree.get("parameters/hurt_tr/active"):
		is_locked = false
	
	if is_locked:
		return

	if Input.is_action_pressed("kick") and is_on_floor():
		animation_tree.set("parameters/hit_tr2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_locked = true
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		animation_tree.set("parameters/in_air/transition_request", "true")

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		visuals.look_at(position + direction)
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if is_on_floor():
		animation_tree.set("parameters/in_air/transition_request", "false")
		
		if input_dir.x != 0 or input_dir.y != 0:
			if running:
				animation_tree.set("parameters/movement/transition_request", "run")
			else:
				animation_tree.set("parameters/movement/transition_request", "walk")
		else:
			animation_tree.set("parameters/movement/transition_request", "idle")
		
	move_and_slide()


func _on_sword_hit_area_entered(area):
	print("hit")
	if area.is_in_group("enemy"):
		print('sdf')
		area.take_damage()


func take_damage(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	animation_tree.set("parameters/hurt_tr/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
